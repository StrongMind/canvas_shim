module PipelineService
  module Serializers
    class ModuleItem
      def initialize(object:)
        @object = object
        @course_id = @object.try(:course_id)
        @module_id = @object.context_module_id
      end

      def self.additional_identifier_fields
        [Models::Identifier.new(:context_id, alias: :course_id)]
      end

      def call
        fetch
      end

      private

      attr_reader :object

      def domain
        ENV['CANVAS_DOMAIN']
      end

      def endpoint
        [
          protocol, domain, ':', port,
          "/api/v1/courses/#{@course_id}/modules/#{@module_id}/items/#{@object.id}"
        ].join('')
      end

      def use_ssl?
        ENV['CANVAS_SSL'] == 'true'
      end

      def port
        return '3000' if Rails.env == 'development'
        return '443' if use_ssl?
        '80'
      end

      def headers
        { Authorization: "Bearer #{ENV['STRONGMIND_INTEGRATION_KEY']}" }
      end

      def fetch
        PipelineService::HTTPClient.get(endpoint, headers: headers).parsed_response
      end

      def course_id
        @course_id
      end

      def protocol
        return 'https://' if use_ssl?
        'http://'
      end
    end
  end
end
