Announcement.class_eval do
  def toggle_pin(pin_announcements)
    if pin_announcements.include?(announcement.id.to_s)
      announcement.update(pinned: true) unless announcement.pinned
    elsif announcement.pinned
      announcement.update(pinned: false)
    end
  end
end