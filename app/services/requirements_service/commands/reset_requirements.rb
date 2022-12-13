module RequirementsService
  module Commands
    class ResetRequirements
      def initialize(context_module:, assignment_group_name:)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @assignment_group_name = assignment_group_name
      end

      def call
        reset_requirements
        update_completion_requirements
      end

      private
      attr_reader :context_module, :completion_requirements, :exam, :assignment_group_name

      def update_completion_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def reset_requirements
        completion_requirements.each do |requirement|
          reset_individual_requirement(requirement)
        end
      end
        
      def reset_individual_requirement(requirement)
        content_tag = get_content_tag(requirement)
        return unless content_tag
        passing_threshold_group_name = case content_tag.content_type
          when 'DiscussionTopic'
            content_tag.content.assignment.passing_threshold_group_name
          when 'Assignment'
            content_tag.content.passing_threshold_group_name
          else
            return
          end
        return unless passing_threshold_group_name == assignment_group_name
        requirement.delete(:min_score)
        requirement.merge!(type: requirement_type(content_tag))
      end
 
      def requirement_type(content_tag)
        case content_tag.content_type
        when "DiscussionTopic"
          "must_contribute"
        else
          "must_submit"
        end
      end

      def skippable_requirement?(req)
        return true unless req[:min_score]
      end

      def get_content_tag(requirement)
        ContentTag.find_by(id: requirement[:id])
      end
    end
  end
end
