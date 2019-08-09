module RequirementsService
  module Queries
    class GetOriginalRequirements
      def initialize(course:)
        @course = course
        @requirements = SettingsService.get_settings(object: :course, id: course.id)['original_requirements']
      end

      def call
        return {} unless requirements
        get_format
      end

      private
      attr_reader :course, :requirements

      def get_format
        reqs = JSON.parse(requirements)
        reqs.is_a?(Hash) ? reqs : {}
      end
    end
  end
end
