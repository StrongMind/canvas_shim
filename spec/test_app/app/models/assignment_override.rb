class AssignmentOverride < ActiveRecord::Base
  has_many :assignment_override_students
  belongs_to :assignment

  def save_without_broadcasting
    self.save
  end
end
