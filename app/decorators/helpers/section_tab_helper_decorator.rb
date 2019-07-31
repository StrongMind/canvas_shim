SectionTabHelper::AvailableSectionTabs.class_eval do
  def strongmind_to_a
    if is_teacher?
      instructure_to_a
    else
      tabs_without_snapshot
    end
  end

  alias_method :instructure_to_a, :to_a
  alias_method :to_a, :strongmind_to_a

  private
  def tabs_without_snapshot
    instructure_to_a.delete_if do |tab|
      tab_is?(tab, 'TAB_AT_A_GLANCE')
    end
  end

  def is_teacher?
    return false unless @context && @current_user
    @context.teacher_enrollments.find_by(user_id: @current_user.id)
  end
end
