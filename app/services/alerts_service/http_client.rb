module AlertsService
  class HTTPClient
    POST_ENDPOINT = 'http://www.example.com'
    include Singleton
    def self.post(alert)
      HTTParty.post(POST_ENDPOINT, body: alert.as_json)
    end
  end
end