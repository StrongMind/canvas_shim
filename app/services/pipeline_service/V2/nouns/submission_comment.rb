module PipelineService
  module V2
    module Nouns
      class SubmissionComment < Base
        include Api
        include Rails.application.routes.url_helpers
        include PipelineService::Serializers::BaseMethods

        Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

        def initialize(object:)
          @submission_comment = object.ar_model
        end

        def call
          @submission_comment
        end
      end
    end
  end
end
