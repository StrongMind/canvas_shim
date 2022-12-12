module RequirementsService
  module Commands
    class AddUnitItemWithMinScore
      def initialize(context_module:, content_tag:, assignment_group_name:)
        @context_module = context_module
        @content_tag = content_tag
        @course = context_module.course
        @score_threshold = RequirementsService.get_passing_threshold(type: :course, id: course.try(:id), assignment_group_name: assignment_group_name)
      end

      def call
        add_threshold_to_module if gradeable_tag_type? && @score_threshold
      end

      private

      attr_reader :context_module, :content_tag, :course, :score_threshold

      def gradeable_tag_type?
        %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(content_tag.content_type)
      end

      def add_threshold_to_module
        context_module.completion_requirements << { :id => content_tag.id, :type => "min_score", :min_score => score_threshold }
        context_module.update_column(:completion_requirements, context_module.completion_requirements)
      end
    end
  end
end
