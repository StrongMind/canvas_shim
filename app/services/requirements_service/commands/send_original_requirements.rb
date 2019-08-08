module RequirementsService
  module Commands
    class SendOriginalRequirements
      def initialize(course:)
        @course = course
      end

      def call
        return unless course
        send_originals
      end

      private
      attr_reader :course
      def originals_json
        course.context_modules.map do |cm|
          {"#{cm.id}" => cm.completion_requirements}
        end.to_json
      end

      def send_originals
        SettingsService.update_settings(
          object: "course",
          id: course.id,
          setting: "original_requirements",
          value: originals_json
        )
      end
    end
  end
end