module PipelineService
  module Serializers
    class ContextModule
      include FakeApi
      include Api::V1::ContextModule

      def initialize(object:)
        @object = object
        @context_module = ::ContextModule.find(@object.id)
        @course_id = @context_module.context_id
      end

      def call
        module_json(@context_module, admin, nil)
      end

      def self.additional_identifier_fields
        [ Models::Identifier.new(:context_id, alias: :course_id) ]
      end

      private

      attr_reader :object

      def course_id
        ::DiscussionTopic.find(object.id).context_id
      end
    end
  end
end
