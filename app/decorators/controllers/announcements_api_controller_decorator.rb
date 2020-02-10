AnnouncementsApiController.class_eval do
  def bulk_pin
    get_context
    get_announcements
    Announcement.transaction do
      @announcements.each do |announcement|
        if pin_announcements.include?(announcement.id.to_s)
          announcement.update(pinned: true) unless announcement.pinned
        elsif announcement.pinned
          announcement.update(pinned: false)
        end
      end
    end

    render :json => @announcements, :status => :ok
  end

  private
  def pin_announcements
    @pin_announcements ||= params.permit(announcement_ids: []).fetch("announcement_ids", [])
  end

  def get_announcements
    @announcements = @context.active_announcements
  end
end
