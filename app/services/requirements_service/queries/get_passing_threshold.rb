module RequirementsService
  module Queries
    class GetPassingThreshold
      def initialize(type:, id: 1, threshold_type: nil)
        @id = id
        @type = type
        setting_name = (type == :school ? "score" : "passing")

        if threshold_type.present? && type == "school"
          @setting = threshold_type
        else
          @setting = "#{threshold_type}_#{setting_name}_threshold"
        end
      end

      def call
        get_threshold
      end

      private
      attr_reader :type, :threshold, :setting, :edited, :id

      def get_threshold
        SettingsService.get_settings(object: type, id: id)["#{@setting}"]
      end
    end
  end
end