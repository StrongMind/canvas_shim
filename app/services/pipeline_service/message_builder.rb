module PipelineService
  class MessageBuilder
    SOURCE = 'canvas'

    def initialize(args)
      @args = args
      @id = args[:id]
      @noun = args[:noun]
      @object = args[:data]
      @domain_name = args[:domain_name]
      @message_class = args[:message_class] || PipelinePublisher::Message
    end

    def build
      message_class.new(
        noun: noun,
        meta: {
          source: SOURCE,
          domain_name: domain_name,
          changes: object.changes
        },
        identifiers: { id: id },
        data: object
      )
    end

    private

    attr_reader :message_class, :id, :noun, :object, :domain_name, :args
  end
end
