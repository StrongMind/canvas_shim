module RequirementsService
  module Commands
    class ResetRequirements
      def initialize(context_module:, exam: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @course = context_module.course
        @old_requirements = RequirementsService.get_original_requirements(
            course: course
          )["#{context_module.id}"]
        @exam = exam
      end

      def call
        return unless old_requirements
        reset_assignments
        update_completion_requirements
      end

      private
      attr_reader :context_module, :completion_requirements, :course, :old_requirements, :exam

      def update_completion_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def reset_assignments
        completion_requirements.each do |req|
          next if skippable_requirement?(req)
          older = find_requirement(req)
          if older
            req.delete("min_score")
            req.merge!(older)
          end
        end
      end

      def skippable_requirement?(req)
        exam ? !unit_exam?(req) : unit_exam?(req)
      end

      def find_requirement(requirement)
        old_requirements.find do |old_req|
          old_req["id"] == requirement["id"]
        end
      end

      def unit_exam?(requirement)
        content_tag = ContentTag.find_by(id: requirement[:id])
        content_tag && RequirementsService.is_unit_exam?(content_tag: content_tag)
      end
    end
  end
end