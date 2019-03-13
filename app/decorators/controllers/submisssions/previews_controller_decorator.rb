Submissions::PreviewsController.class_eval do
  def show
    service = Submissions::SubmissionForShow.new(
      @context, params.slice(:assignment_id, :id, :preview, :version)
    )
    @assignment = service.assignment
    @user       = service.user
    @submission = service.submission

    # StrongMind Added
    @topic = @assignment.discussion_topic

    prepare_js_env
    @assessment_request = @submission.assessment_requests.where(assessor_id: @current_user).first
    @body_classes << 'is-inside-submission-frame'

    if @assignment.moderated_grading?
      @moderated_grading_whitelist = @submission.moderated_grading_whitelist
    end

    unless @assignment.visible_to_user?(@current_user)
      flash[:notice] = t('This assignment will no longer count towards your grade.')
    end

    @headers = false
    if authorized_action(@submission, @current_user, :read)
      if redirect?
        redirect_to(
          named_context_url(
            @context, redirect_path_name, @assignment.quiz.id, redirect_params
          )
        )
      else
        render 'submissions/show_preview'
      end
    end
  end
end
