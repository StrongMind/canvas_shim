module AlertsService
  class Client
    include Singleton

    API_HOST = 'https://www.example.com'

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
        alert.as_json
      ).code
    end

    def list(teacher_id)
      http_client.get(
        "#{API_HOST}/schools/#{school.id}/teachers/#{teacher_id}/alerts"
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
        "#{API_HOST}/schools/#{school.id}/alerts/#{id}"
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
        "#{API_HOST}/schools/#{school.id}/alerts/#{id}"
      ).code
    end

    private

    attr_reader :school

    def http_client
      HTTParty
    end
  end
end