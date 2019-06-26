
module PipelineService
  module V2
    module Nouns 
      class Submission < Base
        include Api::V1::Submission

        def initialize object:
          @ar_object = object.ar_model
        end

        def course_assignment_submission_url(*opts)
        end

        def params
          {includes: ['submission_history']}
        end

        def call
          submission_json(
            @ar_object,
            @ar_object.assignment,
            Account.account_admin,
            {},
            nil,
            ['submission_history']
          )
        end
      end
    end
  end
end