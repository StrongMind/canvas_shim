module RequirementsService
  module Commands
    class SetPassingThreshold
      def initialize(type:, threshold:, edited:, id: 1, threshold_type: nil)
        @type = type
        @threshold = threshold
        setting_name = (type == "school" ? "score" : "passing")
        case threshold_type
        when "exam"
          setting_name += "_exam"
        when "discussion"
          setting_name += "_discussion"
        when "project"
          setting_name += "_project"
        end
        @setting = "#{setting_name}_threshold"
        @edited = (edited == "true")
        @id = id
        @last_threshold = RequirementsService.get_raw_passing_threshold(type: type.to_sym, id: id, threshold_type: threshold_type)
      end

      def call
        return unless id && edited && valid_threshold?
        set_threshold
        Course.find(id)&.touch if type == "course"
      end

      private
      attr_reader :type, :threshold, :setting, :edited, :id, :last_threshold

      def set_threshold
        SettingsService.update_settings(
          object: type,
          id: id,
          setting: setting,
          value: threshold
        )
      end

      def valid_threshold?
        !threshold.negative? && threshold <= 100 && valid_compared_to_last_threshold?
      end

      def valid_compared_to_last_threshold?
        last_threshold.nil? && threshold.positive? ||
        last_threshold.to_f != threshold
      end
    end
  end
end
