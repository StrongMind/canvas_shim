module PipelineService
  module V2
    module Nouns 
      class Submission < Base
        include Api::V1::Submission
        include Rails.application.routes.url_helpers
        Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

        def initialize(object:)
          @submission = object.ar_model
        end

        def params
          { includes: ['submission_history'] }
        end

        def call
          load_attachment
          submission_json(
            @submission,
            @submission.assignment,
            GradesService::Account.account_admin,
            {},
            nil,
            ['submission_history']
          )
        end

        def load_attachment
          submissions = [@submission]
          ::Submission.bulk_load_versioned_attachments(submissions)
          attachments = submissions.flat_map &:versioned_attachments
          ActiveRecord::Associations::Preloader.new.preload(attachments,
          [:canvadoc, :crocodoc_document])
          Version.preload_version_number(submissions)
        end
      end
    end
  end
end