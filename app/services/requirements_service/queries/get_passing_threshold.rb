module RequirementsService
  module Queries
    class GetPassingThreshold
      def initialize(type:, id: 1, threshold_type: nil)
        @type = type
        setting_name = (type == :school ? "score" : "passing")

        case threshold_type
        when "exam"
          setting_name += "_exam"
        when "discussion"
          setting_name += "_discussion"
        when "project"
          setting_name += "_project"
        end

        @setting = "#{setting_name}_threshold"
        @id = id
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
