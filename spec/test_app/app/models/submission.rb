class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user

  after_save :send_unit_grades_to_pipeline

  class ::UnitGrades
    attr_reader :course, :student, :id, :changes
    def initialize(submission)
      @course = submission.assignment.course
      @student = submission.user
      @id = submission.id
      @changes = submission.changes
    end
  end

  def send_unit_grades_to_pipeline
    PipelineService.publish(UnitGrades.new(self))
  end
end
