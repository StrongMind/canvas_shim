module EventService
  class Client
    def initialize(credentials)
      @credentials = credentials

      @conn = Faraday.new(url: "https://#{@credentials[:event_pipeline_host]}") do |faraday|
        faraday.request(:retry, retry_options)
        faraday.headers['Authorization'] = "Bearer #{@credentials[:event_pipeline_token]}"
        faraday.headers['Content-Type'] = 'application/json'
      end
    end

    def retry_options
      {
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2
      }
    end
  end
end
