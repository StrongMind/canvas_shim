module PipelineService
  module Models
    module V2
      class Noun < Models::Noun  
        attr_reader :ar_model
        def initialize(object)
          super(object)
          @ar_model = object
        end
      end
    end
  end
end
