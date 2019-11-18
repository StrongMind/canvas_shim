module PipelineService
  module V2
    module Nouns
      class Submission < Base
        include Api
        include Api::V1::Submission
        include Rails.application.routes.url_helpers
        include PipelineService::Serializers::BaseMethods

        Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

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

        def self.additional_identifier_fields
          [
            Identifier.new(Proc.new {|ar_model| [:assignment_id, ar_model.assignment.id]}),
            Identifier.new(Proc.new {|ar_model| [:course_id, ar_model.assignment.course.id]}),
            Identifier.new(Proc.new {|ar_model| [:created_at, ar_model.created_at]}),
            Identifier.new(Proc.new {|ar_model| [:updated_at, ar_model.updated_at]})
          ]
        end
      end
    end
  end
end
