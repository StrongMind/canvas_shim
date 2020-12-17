class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  belongs_to :associated_user, :class_name => 'User'
  has_many :scores

  after_create :distribute_due_dates
  after_commit { PipelineService.publish(self)}

  def root_account
    Account.new
  end

  def root_account_id
    1
  end

  def computed_current_score
    10
  end

  def active_student?
    self.type == "StudentEnrollment" && self.workflow_state == "active"
  end

  def completed?
    self.workflow_state == "completed"
  end

  def deleted?
    self.workflow_state == "deleted"
  end

  private

  def distribute_due_dates
    AssignmentsService.distribute_due_dates(enrollment: self)
  end
end
