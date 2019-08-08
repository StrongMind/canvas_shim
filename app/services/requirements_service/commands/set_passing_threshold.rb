module RequirementsService
  module Commands
    class SetPassingThreshold
      def initialize(type:, threshold:, edited:, id: 1, exam: false)
        @type = type
        @threshold = threshold
        setting_name = (type == "school" ? "score" : "passing")
        setting_name += "_exam" if exam
        @setting = "#{setting_name}_threshold"
        @edited = (edited == "true")
        @id = id
        @last_threshold = RequirementsService.get_raw_passing_threshold(type: type.to_sym, id: id, exam: exam)
      end

      def call
        return unless id && edited && valid_threshold?
        send_originals if last_threshold.nil? && type == "course"
        set_threshold
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

      def send_originals
        course = Course.find(id)
      end
    end
  end
end