module PipelineService
  module Logger
    ENDPOINT = "https://lrs.strongmind.com/pipeline-watcher-staging"

    def self.log(message)
      HTTParty.post(
        ENDPOINT,
        body: HashWithIndifferentAccess.new(
          JSON.parse(message.to_json)
        ).delete_blank.to_json
      )
    end
  end
end
