UsersController.class_eval do
  def special_programs

    get_context
    @context = @domain_root_account || Account.default unless @context.is_a?(Account)
    @context = @context.root_account

    return unless @context.grants_right?(@current_user, session, :read_sis)

    accommodations = Rails.cache.read("accommodations_#{params[:id]}")
    unless accommodations
      user = User.find(params[:id])
      accommodations = SpecialProgramsService.get_programs(user: user)
      Rails.cache.write("accommodations_#{params[:id]}", accommodations, expires_in: 1.day)
    end
    render :json => { accommodations: accommodations }, :status => :ok
  end

  def observer_enrollments

    return unless observer_dashboard_enabled?

    user = User.find(params[:id])
    return render_unauthorized_action unless user
    contexts = user.observer_enrollments.map(&:course)
    observed_enrollments = ObserverEnrollment.observed_enrollments_for_courses(contexts, user)
    .group_by(&:user_id)
    .map do |k, v|
      user = User.find(k)
      {
        "user" => user.as_json(include_root: false).merge(
          {
            "avatar_image_url" => avatar_image_attrs(k).first,
            "is_online" => user.is_online?,
            "locked_out" => locked_out(user)
          }),
        "enrollments" => v.map do |enr|
          enr.as_json(include_root: false).merge(
            {
              "score" => enr.scores.first,
              "course_name" => enr.course.name
            })
        end
      }
    end.as_json(include_root: false)

    render :json => observed_enrollments, :status => :ok
  end

  def locked_out(student)
    student.pseudonyms.active.any? do |pseudonym|
      AttendanceService.check_lockout(pseudonym: pseudonym)
    end
  end

  def toggle_progress_grade
    user = User.find(params[:id])
    return render_unauthorized_action unless user

    SettingsService.update_settings(
      object: 'user',
      id: user.id,
      setting: "show_progress_grades",
      value: params["show_progress_grades"]
    )

    render :json => {show_progress_grades: params["show_progress_grades"]}, :status => :ok
  end

  def soft_save_with_or_without_identity(user, email)
    begin
      User.transaction { user.save_with_or_without_identity_create(email) }
    rescue
      false
    end
  end

  def provision_identity_v2
    if (@current_user.try(:roles, Account.default) || []).include?("root_admin")
      @user = User.find_by_sis_user_id(params[:sis_user_id])

      if @user && !@user.reload.already_provisioned_in_identity?
        begin
          User.transaction do
            @user.save_with_or_without_identity_create(@user.email, force: true)
          end
        rescue ActiveRecord::RecordInvalid => e
          errors = {
            :errors => {
              :user => @user.errors.as_json[:errors]
            }
          }
          return render :json => errors, :status => :bad_request
        end

        render :json => {}, :status => :ok
      elsif @user
        render :json => {
          :message => t('user_has_already_been_provisioned_in_identity', "User already provisioned in Identity.")
        }, :status => :bad_request
      else
        render :json => {
          :message => t('no_active_user_found_by_sis_id', "No active user found by SIS ID")
        }, :status => :bad_request
      end
    else
      render :json => {
          :message => t('unauthorized_to_provision_id_v2', "Unauthorized to provision in Identity V2")
        }, :status => :unauthorized
    end
  end

  def confirm_provisioning
    if (@current_user.try(:roles, Account.default) || []).include?("root_admin")
      @user = api_find(User, params[:id])
      response = {}

      identity_uuid = @user.pseudonyms.select(&:identity_pseudonym?)
                      .find(&:confirmed_in_identity?).try(:integration_id)
      response.merge!(integration_id: identity_uuid) if identity_uuid

      render :json => response.to_json, :status => :ok
    else
      render :json => {
          :message => t('unauthorized_to_confirm_provisioning', "Unauthorized to Confirm Provisioning")
        }, :status => :unauthorized
    end
  end

  def sis_user_note
    if (@current_user.try(:roles, Account.default) || []).include?("root_admin")
      @user = api_find(User, params[:id])
      note = @user.user_notes.first.try(:note)

      render :json => { sis_user_note: note }, :status => :ok
    else
      render :json => {
          :message => t('unauthorized_to_get_note', "Unauthorized to Get Note")
        }, :status => :unauthorized
    end
  end
end
