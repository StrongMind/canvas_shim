class AssignmentOverride < ActiveRecord::Base
  has_many :assignment_override_students
  belongs_to :assignment
end
