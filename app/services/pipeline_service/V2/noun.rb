module PipelineService
  module V2
    class Noun < Models::Noun  
      attr_reader :ar_model
      def initialize(object)
        super(object)
        @ar_model = object
      end

      def serializer
        PipelineService::V2::Nouns::Base
      end
    end
  end
end
