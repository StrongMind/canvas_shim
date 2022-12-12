module RequirementsService
  module Commands
    class SetPassingThreshold
      def initialize(type:, threshold:, edited:, id: 1, assignment_group_name:)
        @type = type
        @threshold = threshold
        @setting = "#{assignment_group_name}_passing_threshold"
        @edited = (edited == "true")
        @id = id
        @last_threshold = RequirementsService.get_raw_passing_threshold(type: type, id: id, assignment_group_name: assignment_group_name)
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
        last_threshold.to_f != threshold
      end
    end
  end
end