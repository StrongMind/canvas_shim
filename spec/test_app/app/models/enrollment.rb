class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_create :distribute_due_dates

  def root_account
    Account.new
  end

  def computed_current_score
    rand(50..100)
  end

  private

  def distribute_due_dates
    AssignmentsService.distribute_due_dates(enrollment: self)
  end
end
