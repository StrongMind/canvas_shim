module PipelineService
  module Serializers
    class AssignmentGroup
      def initialize object:
        @assignment_group = object
      end

      def self.additional_identifier_fields
        [Models::Identifier.new(:context_id, alias: :course_id)]
      end
      
      def call
        @payload = Builders::AssignmentGroupJSONBuilder.call(@assignment_group) || {}
      end

    end
  end
end
