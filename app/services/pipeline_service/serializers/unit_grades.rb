module PipelineService
  module Serializers
    class UnitGrades
      def initialize(object:)
        @course = object.course
        @student = object.student
        @submission = object.submission
      end

      def call
        UnitsService::Commands::GetUnitGrades.new(
          course: @course,
          student: @student,
          submission: @submission,
        ).call
      end
    end
  end
end
