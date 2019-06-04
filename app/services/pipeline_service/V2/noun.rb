module PipelineService
  module V2
    class Noun < Models::Noun
      attr_reader :ar_model
      def initialize(object)
        super(object)
        @ar_model = object
      end

      def serializer
        case short_class_name
        when /ContentTag/
          PipelineService::V2::Nouns::ContentTag
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
