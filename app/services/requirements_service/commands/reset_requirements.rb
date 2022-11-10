module RequirementsService
  module Commands
    class ResetRequirements
      def initialize(context_module:, exam: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @exam = exam
      end

      def call
        reset_requirements
        update_completion_requirements
      end

      private
      attr_reader :context_module, :completion_requirements, :exam

      def update_completion_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def reset_requirements
        completion_requirements.each do |requirement|
          next if skippable_requirement?(requirement)
          reset_individual_requirement(requirement)
        end  
      end
        
      def reset_individual_requirement(requirement)
        content_tag = get_content_tag(requirement)
        return unless content_tag
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
        exam ? !unit_exam?(req) : unit_exam?(req)
      end

      def unit_exam?(requirement)
        content_tag = get_content_tag(requirement)
        content_tag && RequirementsService.is_unit_exam?(content_tag: content_tag)
      end

      def get_content_tag(requirement)
        ContentTag.find_by(id: requirement[:id])
      end
    end
  end
end
