module PipelineService
  module V2
    module Nouns 
      class Submission < Base
        include Api::V1::Submission
        include Rails.application.routes.url_helpers

        def initialize(object:)
          @submission = object.ar_model
        end

        def params
          { includes: ['submission_history'] }
        end

        def call
          submission_json(
            @submission,
            @submission.assignment,
            GradesService::Account.account_admin,
            {},
            nil,
            ['submission_history']
          )
        end
      end
    end
  end
end