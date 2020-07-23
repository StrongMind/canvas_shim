CourseSection.class_eval do
  after_commit -> { PipelineService::V2.publish self }
end
