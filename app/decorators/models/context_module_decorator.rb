ContextModule.class_eval do
  after_commit -> { PipelineService.publish_as_v2(self, alias: 'module') }
end
