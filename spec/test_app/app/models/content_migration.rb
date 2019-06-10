class ContentMigration < ActiveRecord::Base
  belongs_to :course

  def workflow_state_changed?
    true
  end

  def imported?
    workflow_state == "imported"
  end
end