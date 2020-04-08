AssignmentOverride.class_eval do
  after_create :send_as_unassign, if: :is_unassign_override?

  def is_unassign_override?
    return false if SettingsService.get_settings(object: 'assignment', id: "#{assignment_id}")['unassign_override_id']
    original_due_date = SettingsService.get_settings(object: 'assignment', id: "#{assignment_id}")['original_due_date']
    assignment.only_visible_to_overrides && original_due_date && original_due_date.in_time_zone == due_at.in_time_zone
  end

  def send_as_unassign
    SettingsService.update_settings(
      object: 'assignment',
      id: "#{assignment.id}",
      setting: 'unassign_override_id',
      value: id
    )
  end
end