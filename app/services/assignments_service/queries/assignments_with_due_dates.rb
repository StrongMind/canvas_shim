module AssignmentsService
  module Queries
    class AssignmentsWithDueDates
      def initialize(course:)
        @course  = course
        @modules = ContextModule.where(
          'context_modules.context_id = ? ' +
          'AND context_modules.context_type = \'Course\' ' +
          'AND context_modules.workflow_state = \'active\' ' +
          'AND context_modules.name IS NOT NULL',
          @course.id).order(:position)
      end

      def query
        assignment_list = []

        @modules.each do |context_module|
          context_module.content_tags
            .where(:content_type => ['Assignment', 'DiscussionTopic'])
            .order(:position)
            .map { |tag| assignment_list.push(tag.assignment) }
        end
        assignment_list.compact
      end
    end
  end
end
