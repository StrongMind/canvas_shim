module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
      include Api
      include Api::V1::Submission


      def initialize(object:)
        @object = object
        @admin = PipelineService::Account.account_admin
      end

      def course_assignment_submission_url(one, two, three, four)
        ''
      end

      def params
        {}
      end

      def call
        submission_json(@object, @object.assignment, @admin, {}, nil, [])
      end
    end
  end
end
