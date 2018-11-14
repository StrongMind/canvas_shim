module PipelineService
  module Nouns
    class UnitGrades
      attr_reader :course, :student, :id, :changes
      def initialize(submission)
        @course = submission.assignment.course
        @student = submission.user
        @id = submission.id
        @changes = submission.changes
      end
    end
  end
end
