module IdentifierMapperService
  class Endpoints
    include Singleton
    attr_reader :secret

    def initialize
      @secret ||= SecretManager.get_secret
    end

    def fetch(name, service=nil, identifier=nil)
      api_endpoint +
      case name
      when :get_powerschool_course_id
        "/pairs/?#{service}=#{identifier}"
      when :get_powerschool_info
        "/partners?canvas_domain=#{ENV['CANVAS_DOMAIN']}"
      when :post_canvas_user_id
        "/pairs/"
      end
    end

    def self.fetch(name, service=nil, identifier=nil)
      instance.fetch(name, service, identifier)
    end

    private

    def api_endpoint
      secret['API_ENDPOINT'] + '/api/v1'
    end
  end
end
