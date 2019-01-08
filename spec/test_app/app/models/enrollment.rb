class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_save :distribute_due_dates

  def root_account
    Account.new
  end

  private

  def distribute_due_dates
    return if self.changes[:start_at].nil?
    CoursesService::Commands::SetEnrollmentAssignmentDueDates.new(enrollment: self).call
  end
end
