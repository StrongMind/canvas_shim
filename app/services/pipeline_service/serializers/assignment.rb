module PipelineService
  module Serializers
    class Assignment
      include Api
      include Api::V1::Assignment
      include Rails.application.routes.url_helpers

      Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

      def initialize(object:)
        @object = ::Assignment.find(object.id)
        @course_id = @object.context_id
      end

      def self.additional_identifier_fields
        [Models::Identifier.new(:context_id, alias: :course_id)]
      end

      def call
        assignment_json(@object, GradesService::Account.account_admin, nil)
      end
    end
  end
end
