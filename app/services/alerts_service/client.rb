module AlertsService
  class Client
    include Singleton

    def self.create(alert)
      instance.create(alert)
    end

    def create(alert)
      http_client.post(alert.as_json)
    end
  end
end