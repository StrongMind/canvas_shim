Announcement.class_eval do
  def add_pin(pin_announcements)
    if pin_announcements.include?(id.to_s)
      update(pinned: true) unless pinned
    end
  end

  def remove_pin(pin_announcements)
    if pin_announcements.include?(id.to_s)
      update(pinned: false) if pinned
    end
  end

  def expiration_date?
    @expiration_date ||= SettingsService.get_settings(object: :announcement, id: id)['expiration_date']
  end
end