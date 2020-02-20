AnnouncementsApiController.class_eval do
  def bulk_pin
    get_context
    get_announcements
    Announcement.transaction do
      if params[:unpin] == "true"
        @announcements.each { |ancmt| ancmt.remove_pin(pin_announcements) }
      else
        @announcements.each { |ancmt| ancmt.add_pin(pin_announcements) }
      end
    end

    render :json => @announcements.order("pinned DESC NULLS LAST"), :status => :ok
  end

  private
  def pin_announcements
    @pin_announcements ||= params.permit(announcement_ids: []).fetch("announcement_ids", [])
  end

  def get_announcements
    @announcements = @context.is_a?(Course) ? @context.non_expired_announcements : @context.active_announcements
  end
end
