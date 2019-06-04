module PipelineService
  module Nouns
    class ModuleItem < Models::Noun
      attr_reader :context_id, :context_module_id, :id

      def initialize(content_tag)
        @id = content_tag.id
        @context_id = content_tag.try(:course).try(:id)
        @context_module_id = content_tag.context_module_id
        super
      end

      def serializer
        PipelineService::Serializers::ModuleItem
      end

      def name
        'module_item'
      end

      def self.primary_key
        'id'
      end
    end
  end
end
