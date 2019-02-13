module PipelineService
  module Serializers
    class UnitGrades
      def initialize(object:)
        @submission = ::Submission.find(object.id)
        @course = @submission.course
        @student = @submission.user
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
