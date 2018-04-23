module DomainEvents
  class EventEmitter
    def initialize(args)
      @subscriptions = args[:subscriptions]
      @message = args[:message]
    end

    def call
      subscriptions.each do |name, details|
        next if name != :graded_out
        Events::GradedOut.new(
          listeners: details[:listeners],
          message:   message
        ).call
      end
    end

    private

    attr_reader :subscriptions, :message
  end
end
