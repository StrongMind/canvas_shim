class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_create :distribute_due_dates

  def root_account
    Account.new
  end

  private

  def distribute_due_dates
    AssignmentsService.distribute_due_dates(enrollment: self)
  end
end
