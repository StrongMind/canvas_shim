module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
      def initialize object:
        @object = object
        @course = object.assignment.course
        @assignment = object.assignment
        @user = object.user
      end


      def call
        HTTPClient.get(endpoint, headers: { Authorization: "Bearer #{ENV['STRONGMIND_INTEGRATION_KEY']}"})
      end

      private

      attr_reader :object, :course, :assignment, :user

      def endpoint
        "https://#{ENV['CANVAS_DOMAIN']}/api/v1/courses/#{course.id}/assignments/#{assignment.id}/submissions/#{user.id}"
      end
    end
  end
end
