module DomainEvents
  class EventEmitter
    def initialize(args)
      @subscriptions = args[:subscriptions]
      @message = args[:message]
    end

    def call
      subscriptions.each do |name, subscription|
        Events::GradedOut.new(
          listeners: subscription.listeners,
          message:   message
        ).emit if name == :graded_out
      end
    end

    private

    attr_reader :subscriptions, :message
  end
end
