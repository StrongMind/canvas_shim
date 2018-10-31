module PipelineService
  module Serializers
    class UnitGrades
      def initialize(object:)
        @course = object.course
        @student = object.student
      end

      def call
        UnitsService::Commands::GetUnitGrades.new(
          course: @course,
          student: @student
        ).call
      end
    end
  end
end
