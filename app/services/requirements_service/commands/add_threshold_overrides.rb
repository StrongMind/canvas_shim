module RequirementsService
  module Commands
    class AddThresholdOverrides
      def initialize(context_module:, requirements:)
        @context_module = context_module
        @requirements = requirements
        @course = context_module.course
        @threshold_overrides = SettingsService.get_settings(object: :course, id: course.id)['threshold_overrides']
      end

      def call
        add_threshold_overrides
      end

      private
      attr_reader :context_module, :requirements, :course, :threshold_overrides

      def add_threshold_overrides
        @changed_reqs = []
        requirements.each do |k, v|
          requirement = context_module.completion_requirements.find {|req| req[:id] == k.to_i }
          if requirement && changed_requirement?(v, requirement)
            @changed_reqs << requirement[:id]
          end
        end
        send_overrides_to_settings
      end

      def send_overrides_to_settings
        @all_reqs = conjoin_threshold_overrides(@changed_reqs)
        @all_reqs = @all_reqs.blank? ? false : @all_reqs.join(",")
        SettingsService.update_settings(
          object: 'course',
          id: course.id,
          setting: 'threshold_overrides',
          value: @all_reqs
        )
      end

      def conjoin_threshold_overrides(new_overrides)
        if threshold_overrides
          current_overrides = threshold_overrides.split(",")
          return current_overrides unless new_overrides.any?
          current_overrides.concat(new_overrides).uniq
        elsif new_overrides.any?
          new_overrides
        else
          []
        end
      end

      def changed_requirement?(new_requirement, current_requirement)
        new_requirement["type"] != current_requirement[:type] ||
        (current_requirement[:min_score] && new_requirement[:min_score].to_f != current_requirement[:min_score])
      end
    end
  end
end