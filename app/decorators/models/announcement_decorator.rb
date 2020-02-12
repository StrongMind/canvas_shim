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
end