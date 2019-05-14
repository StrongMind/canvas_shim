module PipelineService
  module V2
    class Payload < Endpoints::Pipeline::MessageBuilder
      def log
        # Payload doesn't log
      end
    end
  end
end