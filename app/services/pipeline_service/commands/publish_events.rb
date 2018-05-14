module PipelineService
  module Commands
    class PublishEvents
      def initialize(object, args={})
        @object = object
      end

      def call
        Events::Emitter.new(object: object).call
      end

      private

      attr_accessor :message, :subscriptions, :changes, :object, :serializer
    end
  end
end
