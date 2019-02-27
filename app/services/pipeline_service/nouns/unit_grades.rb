module PipelineService
  module Nouns
    class UnitGrades
      attr_reader :course, :student, :id, :changes, :submission
      def initialize(submission)
        @course = submission.assignment.course
        @student = submission.user
        @id = submission.id
        @changes = submission.changes
        @submission = submission
      end
    end
  end
end
