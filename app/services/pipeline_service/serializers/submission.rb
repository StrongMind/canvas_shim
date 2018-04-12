module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
      include ::Api
      include ::Api::V1::Submission

      def retrieve_course_external_tools_url(*);end
      def course_assignment_submission_url(*);'';end
      def params;{};end
      def polymorphic_url(*);'';end

      def initialize(object:)
        @object = object
        @admin = PipelineService::Account.account_admin
      end

      def call
        submission_json(@object, @object.assignment, @admin, {}, nil, [])
      end
    end
  end
end
