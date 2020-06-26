module IdentityMapperService
    class Response 
      attr_reader :code, :payload
      def initialize(code, payload)
        @code = code
        @payload = payload
      end
    end
  end