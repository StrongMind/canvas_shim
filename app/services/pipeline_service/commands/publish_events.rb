module PipelineService
  module Commands
    class PublishEvents
      def initialize(object, args={})
        @object        = object
        @subscriptions = args[:subscriptions]
        @changes       = object.changes
      end

      def call
        return unless subscriptions
        grab_changes
        fetch_serializer
        build_message
        emit
      end

      private

      attr_accessor :message, :subscriptions, :changes, :object, :serializer

      def fetch_serializer
        @serializer = Serializers::Fetcher.fetch(object: object)
      end

      def grab_changes
        @changes = object.changes
      end

      def build_message
        @message = serializer.new(object: object).call
      end

      def emit
        Events::Emitter.new(
          message:       message,
          changes:       changes,
          subscriptions: subscriptions
        ).call
      end
    end
  end
end
