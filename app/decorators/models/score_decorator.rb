Score.class_eval do
  after_commit -> { self.enrollment.publish_as_v2 }
end
