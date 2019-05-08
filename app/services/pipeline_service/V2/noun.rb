module PipelineService
  module V2
    class Noun < Models::Noun  
      attr_reader :ar_model
      def initialize(object)
        super(object)
        @ar_model = object
      end

      def serializer
        begin
          "PipelineService::V2::Nouns::#{short_class_name}".constantize
        rescue
          nil
        end
      end
    end
  end
end
