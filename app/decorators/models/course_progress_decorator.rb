CourseProgress.class_eval do
  def module_progressions
    @_module_progressions ||= course.context_module_progressions.
                                  where(user_id: course_progress_user, context_module_id: modules).to_a
  end

  def cache_key(completed: false)
    if completed
      "#{@course.id}/#{course_progress_user.id}/course_progress/requirement_completed_count"
    else
      "#{@course.id}/#{course_progress_user.id}/course_progress/requirement_count"
    end
  end

  def requirements
    # e.g. [{id: 1, type: 'must_view'}, {id: 2, type: 'must_view'}]
    @_requirements ||=
      begin
        if modules.empty?
          []
        else
          fm = modules.first # the visibilites are the same for all the modules - load them all now and reuse them
          user_ids = [course_progress_user.id]
          opts = {
            :is_teacher => false,
            :assignment_visibilities => true, # fm.assignment_visibilities_for_users(user_ids),
            :discussion_visibilities => true, # fm.discussion_visibilities_for_users(user_ids),
            :page_visibilities => true, # fm.page_visibilities_for_users(user_ids),
            :quiz_visibilities => true # fm.quiz_visibilities_for_users(user_ids)
          }
          modules.flat_map { |m| m.completion_requirements_visible_to(course_progress_user, opts) }.uniq
        end
      end
  end

  def requirement_count(cached: false)
    if cached
      count = Rails.cache.read(cache_key)
      return count if count
    end

    cache_and_return_count
  end

  def requirement_completed_count(cached: false)
    if cached
      count = Rails.cache.read(cache_key(completed: true))
      return count if count
    end

    cache_and_return_count(completed: true)
  end

  def cache_and_return_count(completed: false)
    reqs = completed ? requirements_completed : requirements
    count = filter_out_excused_requirements(reqs).size
    Rails.cache.write(cache_key(completed: completed), count)
    count
  end

  def to_json
    if allow_course_progress?
      {
        requirement_count: requirement_count,
        requirement_completed_count: requirement_completed_count,
        next_requirement_url: current_requirement_url,
        completed_at: completed_at
      }
    else
      { error:
          { message: 'no progress available because this course is not module based (has modules and module completion requirements) or the user is not enrolled as a student in this course' }
      }
    end
  end

  private

  def find_user_id
    observer_enrollment ? observer_enrollment.associated_user_id : @user.id
  end

  def course_progress_user
    @course_progress_user ||= User.find(find_user_id)
  end

  def observer_enrollment
    @user.enrollments.where(type: 'ObserverEnrollment', course: course).where.not(associated_user_id: nil).first
  end

  def allow_course_progress?
    (course.module_based? && course.user_is_student?(user, include_all: true)) ||
    (course.module_based? && observer_enrollment && course.user_is_student?(course_progress_user, include_all: true))
  end

  def filter_out_excused_requirements(reqs)
    return reqs unless student_has_excused_submission?
    reqs.select do |req|
      ct = ContentTag.find(req[:id])
      return false unless ct
      sub = get_submissions_from_content_tag(ct)

      if sub
        req unless sub.excused?
      else
        req
      end
    end
  end

  def get_submissions_from_content_tag(ct)
    ct.content.try(:submissions).try(:find_by, { user: course_progress_user }) ||
    ct.content.try(:assignment).try(:submissions).try(:find_by, { user: course_progress_user }) ||
    quiz_submissions(ct)
  end

  def quiz_submissions(item)
    if item.content_type == "Quizzes::Quiz"
      item.content.quiz_submissions.find_by(user: course_progress_user).try(:submission)
    end
  end

  def student_has_excused_submission?
    @user.submissions.exists?(excused: true, context_code: "course_#{@course.id}")
  end
end
