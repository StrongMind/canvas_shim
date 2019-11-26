module PipelineService
  module Nouns
    class Unassigned
      attr_reader :assignment, :id
      def initialize(assignment)
        @assignment = assignment
      end

      def serializer
        PipelineService::Serializers::Unassigned
      end

      def name
        'unassigned'
      end

      def self.primary_key
        'id'
      end

    end
  end
end
