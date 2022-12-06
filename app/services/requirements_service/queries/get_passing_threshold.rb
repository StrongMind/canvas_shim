module RequirementsService
  module Queries
    class GetPassingThreshold
      def initialize(type:, id: 1, assignment_group_name:)
        @id = id
        @type = type
        @setting = "#{assignment_group_name}_passing_threshold"
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