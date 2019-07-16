module AlertsService
  class Endpoints
    include Singleton
    
    attr_reader :secret

    def initialize
      @secret ||= SecretManager.get_secret
    end

    def fetch(name, ids=nil)
      api_endpoint + case name
      when :teacher_alerts
        "/teachers/#{ids[:teacher_id]}/alerts"
      when :course_alerts
        "/courses/#{ids[:course_id]}/alerts"
      when :show_alert, :destroy_alert
        "/alerts/#{ids[:alert_id]}"
      when :create_alert
        "/alerts"
      end
    end

    def self.fetch(name, ids=nil)
      instance.fetch(name, ids)
    end

    private
    
    def api_endpoint
      secret['API_ENDPOINT'] + '/schools/' + self.class.school.id
    end

    def self.school
      School.new(ENV['CANVAS_DOMAIN'])
    end
  end
end