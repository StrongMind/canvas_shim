class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user

  after_update :send_unit_grades_to_pipeline
  after_create :send_unit_grades_to_pipeline

  class ::UnitGrades
    attr_reader :course, :student, :id
    def initialize(submission)
      @course = submission.assignment.course
      @student = submission.user
      @id = submission.id
    end
  end

  def send_unit_grades_to_pipeline
    PipelineService.publish(UnitGrades.new(self))
  end
end
