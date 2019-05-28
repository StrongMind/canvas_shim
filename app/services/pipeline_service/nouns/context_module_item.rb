module PipelineService
  module Nouns
    class ContextModuleItem
      attr_reader :course_id, :context_module_id, :id

      def initialize(content_tag)
        @id = content_tag.id
        @course_id = content_tag.try(:course).try(:id)
        @context_module_id = content_tag.context_module_id
      end

      def self.primary_key
        'id'
      end
    end
  end
end
