module CoursesService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @args = args
        @course = args[:course]
        @modules = ContextModule
                    .where(
                      'context_modules.context_id = ? AND context_modules.context_type = \'Course\' AND context_modules.name IS NOT NULL',
                      @course.id)
                    .order(:position)
      end

      def call
        return unless ::Account.default.feature_enabled?(:auto_due_dates)
        return unless course.start_at && course.end_at
        course_assignments = assignments
        scheduler.course_dates.each do |date, count|
          update_assignments(course_assignments.slice!(0..count - 1), date)
        end
      end

      private

      attr_reader :course, :assignments_per_day

      def scheduler
        @scheduler ||= Scheduler.new(@args.merge(assignment_count: assignments.count))
      end

      def update_assignments(assignments_for_day, date)
        assignments_for_day.each do |assignment|
          next if assignment.nil?
          assignment.update(due_at: date)
        end
      end

      def assignments
        assignment_list = []
        @modules.each do |context_module|
          context_module.content_tags
            .where(:content_type => ['Assignment', 'DiscussionTopic'])
            .order(:position)
            .map { |tag| assignment_list.push(tag.assignment) }
        end
        assignment_list
      end
    end
  end
end
