module RequirementsService
  module Commands
    class ApplyMinimumScoresToUnit
      def initialize(context_module:, force: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @force = force
        @course = context_module.course
        @score_threshold ||= SettingsService.get_settings(object: :course, id: course.try(:id))['passing_threshold'].to_f
      end

      def call
        strip_overrides if force
        return unless threshold_changes_needed?      
        add_min_score_to_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      private

      attr_reader :completion_requirements, :context_module, :course, :force, :score_threshold

      def strip_overrides
        SettingsService.update_settings(
          object: 'course',
          id: course.try(:id),
          setting: 'threshold_overrides',
          value: false
        )
      end

      def threshold_changes_needed?
        return true if force
        return false unless score_threshold.positive?
        completion_requirements.any? do |req|
          ["must_submit", "must_contribute"].include?(req[:type]) ||
          (req[:min_score] && req[:min_score] != score_threshold)
        end
      end

      def get_threshold_overrides
        @threshold_overrides ||= SettingsService.get_settings(object: :course, id: course.try(:id))['threshold_overrides']
      end
    
      def has_threshold_override?(requirement)
        get_threshold_overrides.split(",").map(&:to_i).include?(requirement[:id]) if get_threshold_overrides
      end
    
    
      def skippable_requirement?(requirement)
        has_threshold_override?(requirement) ||
        ["must_submit", "must_contribute", "min_score"].none? { |type| type == requirement[:type] }
      end
    
      def add_min_score_to_requirements
        completion_requirements.each do |requirement|
          next if skippable_requirement?(requirement)
          update_score(requirement)
        end
      end
    
      def update_score(requirement)
        requirement[:type] = "min_score"
        requirement[:min_score] = score_threshold
      end
    end
  end
end


