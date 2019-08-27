module ExcusedService
  def self.bulk_excuse(assignment:, exclusions:)
    Commands::HandleExclusions.new(assignment: assignment, exclusions: exclusions).call
  end

  def self.student_names_ids(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def self.students_in_course(course)
    student_names_ids(course.student_enrollments.where(type: "StudentEnrollment"))
  end
  
  def self.excused_students(assignment)
    submissions = assignment ? assignment.excused_submissions : []
    student_names_ids(submissions)
  end
end