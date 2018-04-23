module DomainEvents
  def self.parse_pipeline_message(message, args={})
    (args[:command] || Commands::ParsePipelineMessage)
      .new(message).call
  end
end
