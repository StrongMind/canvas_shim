Account.class_eval do

  def update_course_passing_requirements
    thresholds = get_assignment_group_thresholds
    courses = self.courses.where('start_at >= ?', Time.zone.now)
    courses.each do |course|
      overridden_group_names = get_overridden_assignment_groups(course)
      thresholds.each do |group_name, value|
        next if !!overridden_group_names&.include?(group_name)
        RequirementsService.set_passing_threshold(
          type: 'course',
          id: course.id,
          edited: 'true',
          threshold: value,
          assignment_group_name: group_name
        )
      end
      course.update_context_module_completion_reqs
    end
  end
  handle_asynchronously :update_course_passing_requirements

  def get_assignment_group_thresholds
    assignment_group_names = AssignmentGroup.passing_threshold_group_names
    thresholds = {}
    assignment_group_names.each do |group_name|
      thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'school', assignment_group_name: group_name)
    end
    thresholds
  end

  def get_overridden_assignment_groups(course)
    SettingsService.get_settings(object: 'course', id: course.id)['assignment_group_threshold_overrides']
  end
end
