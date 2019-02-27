class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_create :distribute_due_dates

  def root_account
    Account.new
  end

  def root_account_id
    1
  end

  def computed_current_score
    10
  end

  private

  def distribute_due_dates
    AssignmentsService.distribute_due_dates(enrollment: self)
  end
end
