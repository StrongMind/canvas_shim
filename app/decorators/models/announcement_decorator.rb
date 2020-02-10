Announcement.class_eval do
  def toggle_pin(pin_announcements)
    if pin_announcements.include?(id.to_s)
      update(pinned: true) unless pinned
    elsif pinned
      update(pinned: false)
    end
  end
end