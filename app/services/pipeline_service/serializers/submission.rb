module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission < Base
      include ::Api
      include ::Api::V1::Submission
      include ActionView::Helpers
      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers

      def params;{};end

      def initialize(object:)
        default_url_options[:host] = host
        @object = object
        @admin = PipelineService::Account.account_admin
      end

      def call
        @current_user = @admin
        submission_json(@object, @object.assignment, @admin, {}, nil, [])
      end
    end
  end
end
