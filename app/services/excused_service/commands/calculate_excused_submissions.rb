module ExcusedService
  module Commands
    class CalculateExcusedSubmissions
      def initialize(enrollment:)
        @enrollment = enrollment
        @course_progress = CourseProgress.new(
          enrollment.course,
          enrollment.user
        )
      end

      def perform
        call
      end

      private
      attr_reader :enrollment, :course_progress

      def call
        return unless valid?
        send_excused_count
      end

      def valid?
        enrollment && enrollment.user && enrollment.course
      end

      def send_excused_count
        SettingsService.update_settings(
          object: 'enrollment',
          id: enrollment.id,
          setting: 'excused_requirement_count',
          value: course_progress.excused_requirement_count
        )
      end
    end
  end
end