module AlertsService
  class Client
    class Response
      attr_reader :payload, :code

      def initialize(code:, payload:)
        @code = code
        @payload = payload
      end
    end
  end
end