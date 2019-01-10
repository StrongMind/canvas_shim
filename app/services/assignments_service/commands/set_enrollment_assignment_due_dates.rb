module AssignmentsService
  module Commands
    class SetEnrollmentAssignmentDueDates
      def initialize(args = {})
         @args = args
         @enrollment = args[:enrollment]
         @user = @enrollment.user
         @course = @enrollment.course
         @assignment_count = @course.assignments.count
         @offset = 0
         @assignments = @course.assignments.order(:due_at).all
      end

      def perform
        self.call
      end

      def call
        return self unless @course.start_at
        distribute_due_dates if @enrollment.created_at > @course.start_at
        self
      end

      private

      def distribute_due_dates
        scheduler.course_dates.each do |date, count|
          (@offset..(@offset + count - 1)).each do |i|
            assignment = @assignments[i]

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

          @offset = @offset + count
        end
      end

      def scheduler
        Scheduler.new(
          @args.merge(
            assignment_count: @assignment_count,
            start_date: @enrollment.created_at,
            course: @course
          )
        )
      end
    end
  end
end
