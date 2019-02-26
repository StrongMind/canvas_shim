module PipelineService
  module Nouns
    class UnitGrades < Base
      attr_reader :course, :student, :id, :changes, :submission
      
      def initialize(submission)
        @course = submission.assignment.course
        @student = submission.user
        @submission = submission
        @id = submission.id
        @changes = submission.changes  
        super(submission)
      end

      private 

      def builder
        Builder
      end
    end
  end
end
