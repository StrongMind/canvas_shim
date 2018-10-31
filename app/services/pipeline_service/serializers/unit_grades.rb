module PipelineService
  module Serializers
    class UnitGrades
      def initialize(object:)
      end

      def call
        # UnitsService::Commands::GetUnitGrades.new()
        return {foo: 'bar'}
      end
    end
  end
end
