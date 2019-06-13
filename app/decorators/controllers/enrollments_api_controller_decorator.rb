class EnrollmentsApiController < ApplicationController
  before_action :get_course_from_section, except: :custom_placement
  before_action :require_context

  def custom_placement
    if !custom_placement_enabled?
      render(:json => { error: 'Custom placement not enabled' }, :status => :unprocessable_entity) and return
    end

    @enrollment  = @context.enrollments.find(params[:id])
    @content_tag = ContentTag.find(params[:content_tag].dig(:id))

    if @enrollment && @content_tag
      # Auto accept invite if pending
      @enrollment.accept if @enrollment.invited?
      @enrollment.user.send_later_if_production_enqueue_args(:custom_placement_at, { priority: Delayed::HIGH_PRIORITY }, @content_tag)

      render :json => {}, :status => :ok
    else
      render :json => {}, :status => :unprocessable_entity
    end

  rescue StandardError => exception
    Raven.capture_exception(exception)
    render :json => {}, :status => :bad_request
  end
end
