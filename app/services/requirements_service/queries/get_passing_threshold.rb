module RequirementsService
  module Queries
    class GetPassingThreshold
      def initialize(type:, id: 1, threshold_type: 'assignment', assignment_group: '')
        @type = type
        setting_name = (type == :school ? "score" : "passing")

        case threshold_type
        when 'assignment'
          setting_name += '_assignment'
          setting_name += "_#{assignment_group}" if assignment_group
          setting_name += '_threshold'
        when 'exam'
          setting_name += '_exam_threshold'
        when 'discussion'
          setting_name += '_discussion_threshold'
        when 'project'
          setting_name += "_project_threshold"
        end

        @setting = setting_name
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
