ContextController.class_eval do
  #
  # Decorate action/view to graph student activity via PageViews for course
  #
  def roster_user_usage
    Chronic.time_class = Time.zone

    if authorized_action(@context, @current_user, :read_reports)
      @user     = @context.users.find(params[:user_id])
      contexts  = [@context] + @user.group_memberships_for(@context).to_a
      @accesses = AssetUserAccess.for_user(@user).polymorphic_where(:context => contexts).most_recent

      @report = PageViewReporter.new(@user, @context)
      @report.run

      respond_to do |format|
        format.html do
          @accesses = @accesses.paginate(page: params[:page], per_page: 50)
          js_env(context_url: context_url(@context, :context_user_usage_url, @user, :format => :json),
                 accesses_total_pages: @accesses.total_pages)
        end
        format.json do
          @accesses = Api.paginate(@accesses, self, polymorphic_url([@context, :user_usage], user_id: @user), default_per_page: 50)
          render :json => @accesses.map{ |a| a.as_json(methods: [:readable_name, :asset_class_name, :icon]) }
        end
      end
    end
  end
end