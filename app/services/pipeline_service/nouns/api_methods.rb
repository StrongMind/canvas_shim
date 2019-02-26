module PipelineService
  module Nouns
    module APIMethods
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

      def request
        Struct.new(:host_with_port, :ssl?, :protocol, :host, :port).new(
          host_with_port, ssl?, protocol, host, port
        )
      end
    end
  end
end
