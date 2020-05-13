Score.class_eval do
  after_save { PipelineService::V2.publish self }
end
