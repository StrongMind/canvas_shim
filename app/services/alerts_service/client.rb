module AlertsService
  class Client
    include Singleton

    Response = Struct.new(:code, :payload)
    API_HOST = 'https://www.example.com'

    def self.create(alert);instance.create(alert);end
    def self.list(school);instance.list(school);end
    def self.show(id);instance.show(id);end
    def self.destroy(id);instance.destroy(id);end

    def create(alert)
      http_client.post(
        "#{API_HOST}/schools/#{school_id}/alerts", 
        alert.as_json
      ).code
    end

    def list(school)
      http_client.get(
        "#{API_HOST}/schools/#{school_id}/alerts"
      ).tap do |response|
        return Response.new(
          response.code,
          Alerts::MaxAttemptsReached.list_from_json(
            response.body
          )
        )
      end
    end

    def show(id)      
      http_client.get(
        "#{API_HOST}/schools/#{school_id}/alerts/#{id}"
      ).tap do |response|
        return Response.new(
          response.code,
          Alerts::MaxAttemptsReached.from_json(
            response.body
          )
        )
      end
    end

    def destroy(id)
      http_client.delete(
        "#{API_HOST}/schools/#{school_id}/alerts/#{id}"
      ).code
    end

    private

    def school_id
      Base64.urlsafe_encode64(school_name)
    end

    def school_name
      ENV['CANVAS_HOST']
    end

    def http_client
      HTTParty
    end
  end
end