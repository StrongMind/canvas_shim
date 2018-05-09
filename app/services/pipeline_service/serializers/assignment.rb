module PipelineService
  # This ugly thing lets us call the canvas assignment api
  module Serializers
    class Assignment
      include ::Api
      include ::Api::V1::Assignment
      include ActionView::Helpers
      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers

      def initialize(object:)
        default_url_options[:host] = host
        @object = object
      end

      def call
        fetch_admin
        assignment_json(object, admin, {})
      end

      private

      attr_reader :object, :admin, :host

      def fetch_admin
        @admin = Account.account_admin
      end

      def host
        ENV['CANVAS_DOMAIN']
      end
    end
  end
end
