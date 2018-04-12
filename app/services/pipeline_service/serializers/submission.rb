module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
      include ::Api
      include ::Api::V1::Submission
      include ActionView::Helpers
      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers



      def avatar_url_for_user(*);'';end
      def retrieve_course_external_tools_url(*);'';end
      def course_assignment_submission_url(*);'';end
      def params;{};end
      def polymorphic_url(*);'';end

      def initialize(object:)
        default_url_options[:host] = ENV['CANVAS_DOMAIN']
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
