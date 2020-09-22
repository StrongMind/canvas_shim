ObserverEnrollment.class_eval do
  def self.observed_enrollments_for_courses(contexts, user)
    contexts = Array(contexts)
    observed_students = []
    Shard.partition_by_shard(contexts) do |sharded_contexts|
      observer_enrollment_data = user.observer_enrollments.active.where(course_id: sharded_contexts)
        .where('associated_user_id IS NOT NULL').pluck(:course_id, :associated_user_id)

      observer_enrollment_data.group_by(&:first).each do |course_id, course_enroll_data|
        associated_user_ids = course_enroll_data.map(&:last)
        students = StudentEnrollment.active.where(user_id: associated_user_ids, course_id: course_id)
        observed_students.concat(students)
      end
    end
    observed_students
  end
end