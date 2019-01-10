module AssignmentsService
  module Commands
    class SetEnrollmentAssignmentDueDates
      def initialize(args = {})
         @args = args
         @enrollment = args[:enrollment]
         @offset = 0
      end

      def perform
        self.call
      end

      def call
        @course = @enrollment.course
        return self unless @course.start_at
        @user = @enrollment.user
        @assignment_count = @course.assignments.count
        @assignments = @course.assignments.order(:due_at).all
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
