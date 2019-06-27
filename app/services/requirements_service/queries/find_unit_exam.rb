module RequirementsService
  module Queries
    class FindUnitExam
      def initialize(content_tag:)
        @content_tag = content_tag
        content_id = content_tag.try(:content_id)
        @assignment = Assignment.find_by(id: content_id)
      end

      def call
        return false unless assignment
        SettingsService.get_settings(
          object: "assignment",
          id: assignment.try(:migration_id)
        )["module_exam"]
      end

      private
      attr_reader :content_tag, :assignment
    end
  end
end