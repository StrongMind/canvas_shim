module RequirementsService
  module Commands
    class DefaultThirdPartyRequirements
      def initialize(context_module:)
        @context_module = context_module
      end

      def call
        set_requirements
        update_completion_requirements
      end

      private
      attr_reader :context_module

      def set_requirements
        context_module.content_tags.each do |tag|
          context_module.completion_requirements << create_requirement(tag)
        end
      end

      def create_requirement(content_tag)
        {
          id: content_tag.id,
          type: requirement_type(content_tag)
        }
      end

      def requirement_type(content_tag)
        case content_tag.content_type
        when "DiscussionTopic"
          "must_contribute"
        else
          "must_submit"
        end
      end

      def update_completion_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end
    end
  end
end
