module RequirementsService
  module Commands
    class DefaultThirdPartyRequirements
      def initialize(context_module:)
        @context_module = context_module
        @completion_requirements = []
      end

      def call
        set_requirements
        update_completion_requirements
      end

      private
      attr_reader :context_module, :completion_requirements

      def set_requirements
        context_module.content_tags.each do |tag|
          existing_req = requirement_exists?(tag)
          if existing_req
            completion_requirements << existing_req
          else
            completion_requirements << create_requirement(tag)
          end
        end
      end

      def requirement_exists?(content_tag)
        context_module.completion_requirements.find { |req| req[:id] == content_tag.id }
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
        when "Assignment", "Quizzes::Quiz"
          "must_submit"
        when "WikiPage", "Attachment"
          "must_mark_done"
        else
          "must_view"
        end
      end

      def update_completion_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end
    end
  end
end
