module AlertsService
  class Client
    include Singleton
    API_HOST = 'https://www.example.com'

    def self.create(alert)
      instance.create(alert)
    end

    def create(alert)
      http_client.post("#{API_HOST}/schools/#{school_id}/alerts", alert.as_json)
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