module PipelineService
  module V2
    class Noun < Models::Noun
      attr_reader :ar_model
      def initialize(object)
        super(object)
        @ar_model = object
        @noun_class = object.class
      end

      def serializer
        case short_class_name
        when /AssignmentGroup/
          PipelineService::V2::Nouns::AssignmentGroup
        else
          PipelineService::V2::Nouns::Base
        end
      end

      def short_class_name
        @noun_class.to_s.split('::').last
      end


    end
  end
end
