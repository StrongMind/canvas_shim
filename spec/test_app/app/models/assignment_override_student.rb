class AssignmentOverrideStudent < ActiveRecord::Base
  belongs_to :assignment_override
  belongs_to :user
  belongs_to :assignment
end
