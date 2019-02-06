module PipelineService
  module Serializers
    class Submission
      def initialize object:
        @object = object
        @course = object.assignment.course
        @assignment = object.assignment
        @user = object.user
        @api_client = Pandarus::Client.new(prefix: prefix, token: ENV['STRONGMIND_INTEGRATION_KEY'])
      end

      def call
        @api_client.get_single_submission_courses(@course.id, @assignment.id, @user.id, include: ['submission_history'])
      end

      def identifiers
        { assignment_id: @assignment.id, course_id: @course.id }
      end

      private

      def prefix
        if Rails.env == 'development'
          "http://#{ENV['CANVAS_DOMAIN']}:3000/api"
        else
          "https://#{ENV['CANVAS_DOMAIN']}/api"
        end
      end

      attr_reader :object, :course, :assignment, :user
    end
  end
end
