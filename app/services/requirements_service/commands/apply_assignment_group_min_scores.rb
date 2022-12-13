module RequirementsService
  module Commands
    class ApplyAssignmentGroupMinScores
      def initialize(context_module:, force: false, assignment_group_name:)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @force = force
        @course = context_module.course
        @settings = SettingsService.get_settings(object: :course, id: course.try(:id))
        @setting_name = "#{assignment_group_name}_passing_threshold"
        @threshold_exists = !!settings["#{@setting_name}"]
        @score_threshold = settings["#{@setting_name}"].to_f
        @threshold_overrides = settings['threshold_overrides']
        @assignment_group_name = assignment_group_name
      end

      def call
        return unless threshold_exists

        if force
          RequirementsService.strip_overrides(course) if threshold_overrides
        else
          return unless threshold_changes_needed?
        end

        run_command
      end

      private

      attr_reader :completion_requirements, :context_module, :course, :force, :score_threshold, :threshold_overrides, :settings, :threshold_exists, :assignment_group_name

      def run_command
        if score_threshold.zero?
          reset_requirements
        else
          add_min_score_to_requirements
          finalize_update
        end
      end

      def reset_requirements
        RequirementsService.reset_requirements(context_module: context_module, assignment_group_name: assignment_group_name)
      end

      def finalize_update
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def threshold_changes_needed?
        return false unless score_threshold.positive?
        completion_requirements.each do |req|
          is_submittable?(req) || min_score_different_than_threshold?(req)
        end
      end

      def is_submittable?(req)
        ["must_submit", "must_contribute"].include?(req[:type])
      end

      def min_score_different_than_threshold?(req)
        (req[:min_score] && req[:min_score] != score_threshold)
      end
    
      def has_threshold_override?(requirement)
        threshold_overrides.split(",").map(&:to_i).include?(requirement[:id]) if threshold_overrides
      end

      def skippable_requirement?(requirement)
        content_tag = ContentTag.find(requirement[:id])
        passing_threshold_group_name = case content_tag.content_type
                                when 'DiscussionTopic'
                                  content_tag.content.assignment.passing_threshold_group_name
                                when 'Assignment'
                                  content_tag.content.passing_threshold_group_name
                                else
                                  return true
                                end
        has_threshold_override?(requirement) || !["must_submit", "must_contribute", "min_score"].include?(requirement[:type]) || passing_threshold_group_name != assignment_group_name
      end

      def add_min_score_to_requirements
        completion_requirements.each do |requirement|
          next if skippable_requirement?(requirement)
          update_score(requirement)
        end
      end
    
      def update_score(requirement)
        content_tag = ContentTag.find_by(id: requirement[:id])
        min_score = RequirementsService.percentify_min_score(
                      content_tag: content_tag,
                      passing_threshold: score_threshold
                    )
        requirement.merge!(type: 'min_score', min_score: min_score)
      end

      def unit_exam?(requirement)
        content_tag = ContentTag.find_by(id: requirement[:id])
        content_tag && RequirementsService.is_unit_exam?(content_tag: content_tag)
      end

      def not_unit_exam?(requirement)
        !unit_exam?(requirement)
      end

    end
  end
end