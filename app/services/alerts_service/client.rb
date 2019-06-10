module AlertsService
  class Client
    include Singleton

    API_HOST = 'https://kom06r8apf.execute-api.us-west-2.amazonaws.com/dev'

    def initialize
      @school = School.new(ENV['CANVAS_DOMAIN'])
    end

    def self.create(alert);instance.create(alert);end
    def self.list(teacher_id);instance.list(teacher_id);end
    def self.show(id);instance.show(id);end
    def self.destroy(id);instance.destroy(id);end

    def create(alert)
      http_client.post(
        "#{API_HOST}/schools/#{school.id}/alerts", 
        body: alert.to_json,
        headers: headers,
      ).code
    end

    def list(teacher_id)
      http_client.get(
        "#{API_HOST}/schools/#{school.id}/teachers/#{teacher_id}/alerts",
        headers: headers
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
        "#{API_HOST}/schools/#{school.id}/alerts/#{id}",
        headers: headers
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
        "#{API_HOST}/schools/#{school.id}/alerts/#{id}",
        headers: headers
      ).code
    end

    private

    attr_reader :school

    def headers
      { 
        'x-api-key' => ENV['MY_ID'],
        'Content-Type' => 'application/json'
      }
    end

    def http_client
      HTTParty
    end
  end
end