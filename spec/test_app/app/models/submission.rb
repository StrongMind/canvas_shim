class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :course
  has_many :versions, class_name: 'SubmissionVersion'
  has_many :submission_comments

  after_save :send_submission_to_pipeline
  after_save :send_unit_grades_to_pipeline

  def send_unit_grades_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['enable_unit_grade_calculations'] == true
    PipelineService.publish(PipelineService::Nouns::UnitGrades.new(self))
  end

  def send_submission_to_pipeline
    PipelineService.publish self
  end
end
