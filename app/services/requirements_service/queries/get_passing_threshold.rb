module RequirementsService
  module Queries
    class GetPassingThreshold
      def initialize(type:, id: 1, exam: false)
        @type = type
        setting_name = (type == :school ? "score" : "passing")
        setting_name += "_exam" if exam
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