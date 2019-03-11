module PipelineService
  module Commands
    class PublishEvents
      def initialize(args={})
        @args = args
      end

      def call
        self.class.emitter.new(@args).call
      end

      def self.emitter
        Events::Emitter
      end
    end
  end
end
