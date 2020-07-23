module IdentifierMapperService
  class Client
    include Singleton

    def get_powerschool_school_id
      response = get(endpoints(
        :get_powerschool_info
      ))
      return nil if response.code != 200

      response.payload.try(:first).try(:fetch, "powerschool_school_number", nil)
    end

    def get_powerschool_info
      response = get(endpoints(:get_powerschool_info))
      return nil if response.code != 200 || response.payload.empty?
      {
        "name": response.payload.first["name"],
        "canvas_domain": response.payload.first["canvas_domain"],
        "canvas_account": response.payload.first["canvas_account"],
        "powerschool_domain": response.payload.first["powerschool_domain"],
        "powerschool_dcid": response.payload.first["powerschool_dcid"],
        "powerschool_school_number": response.payload.first["powerschool_school_number"],
        "fuji_id": response.payload.first["fuji_id"],
        "default_grade": response.payload.first["default_grade"]
      }
    end

    def get_powerschool_course_id(course_id)
      response = get(endpoints(
        :get_powerschool_course_id,
        service="com.instructure.canvas.courses",
        identifier=course_id
      ))
      return nil if response.code != 200
      response.payload.map {|p| p.dig("com.powerschool.class.dcids", get_powerschool_info[:name])}.first
    end

    def post_canvas_user_id(canvas_user_id, identity_uuid)
      return unless canvas_user_id && identity_uuid
      school_name = get_powerschool_info.try(:fetch, :name, nil)
      return unless school_name

      params = {
        "com.strongmind.identity.user.id": identity_uuid,
        "com.instructure.canvas.users": { "#{school_name}": canvas_user_id }
      }

      post(endpoints(:post_canvas_user_id), params.to_json) == 201
    end

    private 

    def get(endpoint)
      http_client.get(endpoint, headers: headers).tap do |response|
        return Response.new(
          response.code, response.parsed_response
        )
      end
    end

    def post(endpoint, params)
      http_client.post(endpoint, headers: headers, body: params).tap do |response|
        return Response.new(
          response.code, response.parsed_response
        )
      end
    end

    def headers
      {
        'Authorization' => "Token #{SecretManager.get_secret['TOKEN']}",
        'Content-Type' => 'application/json'
      }
    end

    def endpoints(name, service=nil, identifier=nil)
      Endpoints.fetch(name, service, identifier)
    end

    def http_client
      HTTParty
    end

    class << self
      extend Forwardable
      # This trick makes it so we don't have to define a bunch 
      # of class methods just to forward to the instance
      #
      # ie: def self.foo(bar); instance.foo(bar); end
      # the splat operator turns the array
      def_delegators :instance, *Client.instance_methods(false)
    end
  end
end
