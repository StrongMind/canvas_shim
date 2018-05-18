module PipelineService
  module Commands
    class PublishEvents
      def initialize(args={})
        @args = args
      end

      def call
        Events::Emitter.new(@args).call
      end
    end
  end
end
