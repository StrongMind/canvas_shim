Score.class_eval do
  after_commit :publish_enrollment_as_v2

  def publish_enrollment_as_v2
    if enrollment.type == "StudentEnrollment"
      enrollment.publish_as_v2
    end
  end
end
