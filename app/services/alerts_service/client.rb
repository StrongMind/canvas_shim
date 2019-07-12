module AlertsService
  class Client
    include Singleton

    def initialize
      @school = School.new(ENV['CANVAS_DOMAIN'])
    end

    def self.create(alert_type, attributes);instance.create(alert_type, attributes={});end
    def self.list(teacher_id);instance.list(teacher_id);end
    def self.show(id);instance.show(id);end
    def self.destroy(id);instance.destroy(id);end

    def create(alert_type, attributes)
      alert = Alerts.const_get(alert_type.to_s.camelize).new(attributes)
      http_client.post(
        "#{get_secret['API_ENDPOINT']}/schools/#{school.id}/alerts", 
        body: alert.to_json,
        headers: headers,
      ).tap do |response|
        return Response.new(response.code, nil)
      end
    end

    def list(teacher_id)
      http_client.get(
        "#{get_secret['API_ENDPOINT']}/schools/#{school.id}/teachers/#{teacher_id}/alerts",
        headers: headers
      ).tap do |response|
        return Response.new(
          response.code,
          Alert.list_from_json(response.body)
        )
      end
    end

    def show(id)      
      http_client.get(
        "#{get_secret['API_ENDPOINT']}/schools/#{school.id}/alerts/#{id}",
        headers: headers
      ).tap do |response|
        return Response.new(
          response.code,
          Alert.from_json(response.body)
        )
      end
    end

    def destroy(id)
      http_client.delete(
        "#{get_secret['API_ENDPOINT']}/schools/#{school.id}/alerts/#{id}",
        headers: headers
      ).tap do |response|
        return Response.new(response.code, nil)
      end
    end

    private

    attr_reader :school

    def get_secret
      @secret ||= SecretManager.get_secret
    end

    def headers
      { 
        'x-api-key' => get_secret['API_KEY'],
        'Content-Type' => 'application/json'
      }
    end

    def http_client
      HTTParty
    end
  end
end