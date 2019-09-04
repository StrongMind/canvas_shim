module UnitsService
  module Commands
    class GetUnitGrades
      def initialize(course:, student:, submission:)
        @course = course
        @student = student
        @submission = submission
      end

      def call
        calculate_grades
        payload
      end

      private

      def get_sis_user_id
        return unless @student.respond_to?(:pseudonym)
        @student.pseudonym.try(:sis_user_id)
      end

      def unit_submissions
        @unit_submissions ||= UnitsService::Queries::GetSubmissions.new(
          course: @course,
          student: @student
        ).query
      end

      def student_enrollment
        UnitsService::Queries::GetEnrollment.query(course: @course, user: @student)
      end

      def payload
        {
          school_domain: ENV['CANVAS_DOMAIN'],
          course_id: @course.id,
          course_score: student_enrollment.computed_current_score,
          student_id: @student.id,
          sis_user_id: get_sis_user_id,
          submitted_at: @submission.submitted_at,
          units: all_units
        }
      end

      def calculate_grades
        @grades = UnitsService::GradesCalculator.new(unit_submissions, @course).call
      end

      def submissions_graded?(unit, score)
        score unless unit_excused?(unit) || unit_submissions[unit].none? { |sub| sub.graded_at && sub.grader_id != GradesService::Account.account_admin.try(:id) }
      end

      def unit_excused?(unit)
        UnitsService::Queries::IsUnitExcused.new(unit: unit, student: @student).query
      end

      def all_units
        @grades.map do |unit, score|
          {
            id: unit.id,
            position: unit.position,
            score: submissions_graded?(unit, score),
            excused: unit_excused?(unit)
          }
        end.concat(excused_units)
      end

      def excused_units
        @course.context_modules.select do |context_module|
          unit_excused?(context_module)
        end.map do |excused_module|
          {
            id: excused_module.id,
            position: excused_module.position,
            score: nil,
            excused: true
          }
        end
      end
    end
  end
end
