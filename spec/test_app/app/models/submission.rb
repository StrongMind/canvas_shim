class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :course
  has_many :versions, class_name: 'SubmissionVersion'
  has_many :submission_comments

  after_save :send_unit_grades_to_pipeline

  def send_unit_grades_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['enable_unit_grade_calculations']
    PipelineService.publish(PipelineService::Nouns::UnitGrades.new(self))
  end

  def self.bulk_load_versioned_attachments(submissions)
    []
  end

  def versioned_attachments
  end

  def missing?
    return unless assignment
    (assignment.due_at || 1.day.from_now) < Time.now && !submitted_at
  end

  def late?
    return unless assignment && submitted_at
    (assignment.due_at || 1.day.from_now) < Time.now &&
    submitted_at < (assignment.due_at || submitted_at - 1.day)
  end
end
