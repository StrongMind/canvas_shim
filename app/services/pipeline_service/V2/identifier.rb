module PipelineService
  module V2
    class Identifier < PipelineService::Models::Identifier
      def to_a(instance)
        instance = instance.ar_model
        super
      end
    end
  end
end