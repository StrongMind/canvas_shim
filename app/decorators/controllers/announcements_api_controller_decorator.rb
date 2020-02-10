AnnouncementsApiController.class_eval do
  def bulk_pin
    get_context
    get_announcements
    Announcement.transaction do
      @announcements.each do |announcement|
        announcement.toggle_pin(pin_announcements)
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
