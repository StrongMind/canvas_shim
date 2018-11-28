class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :versions, class_name: 'SubmissionVersion'

  after_save :send_unit_grades_to_pipeline

  def send_unit_grades_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['enable_unit_grade_calculations'] == true
    PipelineService.publish(PipelineService::Nouns::UnitGrades.new(self))
  end
end
