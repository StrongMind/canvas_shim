module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
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

      def request
        Struct.new(:host_with_port, :ssl?, :protocol, :host, :port).new(
          host_with_port,
          ssl?,
          protocol,
          host,
          port
        )
      end

      def call
        @current_user = @admin
        submission_json(@object, @object.assignment, @admin, {}, nil, [])
      end

      private

      def protocol
        ENV['CANVAS_SSL'] == 'true' ? 'https://' : 'http://'
      end

      def host
        ENV['CANVAS_DOMAIN']
      end

      def port
        80
      end

      def host_with_port
        "#{host}:#{port}"
      end

      def ssl?
        ENV['CANVAS_SSL'] == 'true'
      end
    end
  end
end
