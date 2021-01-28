module PipelineService
  module Serializers
    class ContextModule
      include Api
      include Api::V1::ContextModule
      include Rails.application.routes.url_helpers

      Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

      def initialize(object:)
        @object = object
        @context_module = ::ContextModule.find(@object.id)
        @course_id = @context_module.context_id
      end

      def call
        module_json(@context_module, GradesService::Account.account_admin, nil, nil, ['items'])
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
