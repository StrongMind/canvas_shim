module PipelineService
  module Nouns
    class Unassigned
      attr_reader :assignment
      def initialize(assignment)
        @assignment = assignment
      end

      def serializer
        PipelineService::Serializers::Unassigned
      end

      def name
        'unassigned'
      end

    end
  end
end
