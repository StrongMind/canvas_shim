module AlertsService
  class Client
    include Singleton


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

    def course_teacher_alerts(course_id:, teacher_id:)
      get(endpoints(:course_teacher_alerts, course_id: course_id, teacher_id: teacher_id))
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

    class << self
      extend Forwardable
      # This trick makes it so we don't have to define a bunch 
      # of class methods just to forward to the instance

      def_delegators :instance, *(Client.instance_methods - Object.methods - [:_dump])
    end
  end
end
