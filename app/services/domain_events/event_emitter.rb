module DomainEvents
  class EventEmitter
    def initialize(args)
      @subscriptions = args[:subscriptions]
      @message = args[:message]
    end

    def call
      subscriptions.each do |name, subscription|
        next if name != :graded_out
        Events::GradedOut.new(
          listeners: subscription.listeners,
          message:   message
        ).emit
      end
    end

    private

    attr_reader :subscriptions, :message
  end
end
