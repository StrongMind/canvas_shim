class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user

  after_save :send_unit_grades_to_pipeline

  def send_unit_grades_to_pipeline
    PipelineService.publish(PipelineService::Nouns::UnitGrades.new(self))
  end
end
