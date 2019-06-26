module RequirementsService
  module Commands
    class SetPassingThreshold
      def initialize(type:, threshold:, edited:, id: 1)
        @type = type
        @threshold = threshold
        setting_name = (type == "school" ? "score" : "passing")
        @setting = "#{setting_name}_threshold"
        @edited = (edited == "true")
        @id = id
      end

      def call
        return unless id && edited && valid_threshold?
        set_threshold
      end

      private
      attr_reader :type, :threshold, :setting, :edited, :id

      def set_threshold
        SettingsService.update_settings(
          object: type,
          id: id,
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