module PipelineService
  module V2
    def self.publish(model)
      begin
        V2::API::Publish.new(model).call
      rescue StandardError => exception
        Raven.captureException(exception)
      end
    end
  end
end
