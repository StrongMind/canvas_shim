module PipelineService
  module Serializers
    class Submission
      def initialize object:
        @object = ::Submission.find(object.id)
        @course = @object.assignment.course
        @assignment = @object.assignment
        @user = @object.user
        @api_client = Pandarus::Client.new(
          prefix: prefix, 
          token: ENV['STRONGMIND_INTEGRATION_KEY']
        )
      end

      def call
        @api_client.get_single_submission_courses(
          @course.id, 
          @assignment.id, 
          @user.id, 
          include: ['submission_history']
        )
      end

      def self.additional_identifier_fields
        [
          Models::Identifier.new(:assignment_id), 
          Models::Identifier.new(course_identifier)
        ]
      end

      private

      def self.course_identifier
        Proc.new do |submission|
          return [:course_id, nil] unless 
            submission.assignment && 
            submission.assignment.course
          [:course_id, submission.assignment.course.id] 
        end
      end

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
