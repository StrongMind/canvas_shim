Account.class_eval do

  def update_course_passing_requirements
    thresholds = get_assignment_group_thresholds
    courses = self.courses.where('start_at >= ?', Time.zone.now)
    courses.each do |course|
      thresholds.each do |group_name, value|
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
    assignment_group_names = AssignmentGroup::GROUP_NAMES.map{|n| n.downcase.gsub(/\s/, "_")}
    thresholds = {}
    assignment_group_names.each do |group_name|
      thresholds[group_name] = RequirementsService.get_passing_threshold(type: 'school', assignment_group_name: group_name)
    end
    thresholds
  end
end
