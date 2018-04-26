module PipelineService
  module Events
    def self.parse_pipeline_message(message, args={})
      (args[:command] || Commands::RunEvents)
        .new(message).call
    end
  end
end
