module RequirementsService
  module Commands
    class SetNewThreshold
      def initialize(type:, threshold:, edited:)
        @type = type
        @threshold = threshold
        setting_name = (type == "school" ? "score" : "passing")
        @setting = "#{setting_name}_threshold"
        @edited = (edited == "true")
      end

      def call
        return unless edited && valid_threshold?
        set_threshold
      end

      private
      attr_reader :type, :threshold, :setting, :edited

      def set_threshold
        SettingsService.update_settings(
          object: type,
          id: 1,
          setting: setting,
          value: threshold
        )
      end

      def valid_threshold?
        !threshold.negative? && threshold <= 100
      end
    end
  end
end