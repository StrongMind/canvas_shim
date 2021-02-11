Score.class_eval do
  after_commit -> { self.enrollment.publish_as_v2 }


  def publish_enrollment_as_v2
    if self.enrollment.type == "StudentEnrollment"
      self.enrollment.publish_as_v2
    end
  end

end
