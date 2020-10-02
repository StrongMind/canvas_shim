module AssignmentsService
  module Queries
    class AssignmentsWithDueDates
      def initialize(course:)
        @course  = course
        @modules = ContextModule.where(
          'context_modules.context_id = ? ' +
          'AND context_modules.context_type = \'Course\' ' +
          'AND context_modules.workflow_state <> \'deleted\' ' +
          'AND context_modules.name IS NOT NULL',
          @course.id).order(:position)
      end

      def query
        assignment_list = []

        @modules.each do |context_module|
          context_module.content_tags
            .where(:content_type => ['Assignment', 'DiscussionTopic', 'Quizzes::Quiz'])
            .order(:position)
            .map do |tag|
              assignment_list.push(
                add_to_list(tag)
              )
            end
        end
        assignment_list.compact
      end

      def add_to_list(tag)
        tag.content.is_a?(Quizzes::Quiz) ? tag.content : tag.assignment
      end
    end
  end
end
