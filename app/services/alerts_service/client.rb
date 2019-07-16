module AlertsService
  class Client
    include Singleton

    def self.create(alert_type, attributes);instance.create(alert_type, attributes);end
    def self.teacher_alerts(teacher_id);instance.teacher_alerts(teacher_id);end
    def self.course_alerts(course_id);instance.course_alerts(course_id);end
    def self.show(id);instance.show(id);end
    def self.destroy(id);instance.destroy(id);end

    def create(alert_type, attributes)
      alert = Alerts.const_get(alert_type.to_s.camelize).new(attributes)
      http_client.post(
        endpoints(:create_alert),
        body: alert.to_json,
        headers: headers
      ).tap do |response|
        return Response.new(response.code, nil)
      end
    end

    def teacher_alerts(teacher_id)
      get(endpoints(:teacher_alerts, teacher_id: teacher_id))
    end

    def course_alerts(course_id)
      get(endpoints(:course_alerts, course_id: course_id))
    end

    def show(id)
      get(endpoints(:show_alert, alert_id: id))
    end

    def destroy(id)
      http_client.delete(
        endpoints(:destroy_alert, alert_id: id),
        headers: headers
      ).tap do |response|
        return Response.new(response.code, nil)
      end
    end

    private

    def get(endpoint)
      http_client.get(
        endpoint, headers: headers
      ).tap do |response|
        return Response.new(
          response.code, Alert.from_json(response.body)
        )
      end
    end

    def headers
      {
        'x-api-key' => SecretManager.get_secret['API_KEY'],
        'Content-Type' => 'application/json'
      }
    end

    def endpoints(name, ids=nil)
      Endpoints.fetch(name, ids)
    end

    def http_client
      HTTParty
    end
  end
end
