class EnrollmentsApiController < ApplicationController
  before_action :get_course_from_section, except: :custom_placement
  before_action :require_context

  def custom_placement
    @enrollment  = @context.enrollments.find(params[:id])
    @content_tag = ContentTag.find(params[:content_tag].dig(:id))

    if @enrollment && @content_tag
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
