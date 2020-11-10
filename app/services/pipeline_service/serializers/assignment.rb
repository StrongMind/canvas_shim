module PipelineService
  module Serializers
    class Assignment
      def initialize(object:)
        @object = ::Assignment.find(object.id)
        @course_id = @object.course.id
      end

      def self.additional_identifier_fields
        [Models::Identifier.new(:context_id, alias: :course_id)]
      end

      def call
        @object.as_json(:permissions => {:user => GradesService::Account.account_admin, :session => nil})
      end
    end
  end
end