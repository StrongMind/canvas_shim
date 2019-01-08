module CoursesService
  module Commands
    class SetEnrollmentAssignmentDueDates
      def initialize(args = {})
         @args = args
         @enrollment = args[:enrollment]
         @user = @enrollment.user
         @course = @enrollment.course
         @assignment_count = @course.assignments.count
      end

      def call
        scheduler = Scheduler.new(
          @args.merge(
            assignment_count: @assignment_count,
            start_date: @enrollment.start_at,
            course: @course
          )
        )




        #   update_assignments(course_assignments.slice!(0..count - 1), date)
        # end

        offset = 0
        assignments = @course.assignments.order(:due_at).all

        scheduler.course_dates.each do |date, count|
          (offset..(offset + count - 1)).each do |i|
            assignment = assignments[i]

            ao = AssignmentOverride.create(
              assignment: assignment,
              due_at: date
            )
            AssignmentOverrideStudent.create(
              assignment_override: ao,
              user: @user,
              assignment: assignment
            )
          end

          offset = offset + count
        end
      end
    end
  end
end
