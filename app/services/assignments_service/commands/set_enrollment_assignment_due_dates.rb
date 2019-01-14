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
        return unless SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on'
        return unless SettingsService.get_settings(object: :school, id: 1)['auto_enrollment_due_dates'] == 'on'
        @course = @enrollment.course
        return self unless @course.start_at
        @user = @enrollment.user
        @assignment_count = @course.assignments.count
        @assignments = Queries::AssignmentsWithDueDates.new(course: @course).query
        distribute_due_dates if @enrollment.created_at > @course.start_at
        self
      end

      private

      def distribute_due_dates
        scheduler.course_dates.each do |date, count|
          (@offset..(@offset + count - 1)).each do |i|
            assignment = @assignments[i]
            next unless assignment.due_at

            ao = AssignmentOverride
              .create_with(
                assignment: assignment,
                due_at_overridden: true
              )
              .find_or_create_by(due_at: date)

            ao.title = nil

            AssignmentOverrideStudent.create(
              assignment_override: ao,
              user: @user,
              assignment: assignment
            )

            ao.save
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
