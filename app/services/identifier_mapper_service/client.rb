module IdentifierMapperService
    class Client
        include Singleton

        def get_powerschool_school_id
          response = get(endpoints(
            :get_powerschool_school_id
          ))

          return nil if response.code != 200

          response.payload["powerschool_school_number"]
        end

        def get_powerschool_course_id(course_id)
            response = get(endpoints(
              :get_powerschool_course_id, 
              service: "com.instructure.canvas.courses", 
              identifier: course_id
            ))

            return nil if response.code != 200

            response.payload["com.powerschool.section.dcids"][ENV['CANVAS_DOMAIN'].split('.').first]
        end

        private 

        def get(endpoint)
            http_client.get(
                  endpoint, headers: headers
                ).tap do |response|
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

        def endpoints(name, ids=nil)
          Endpoints.fetch(name, ids)
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
          