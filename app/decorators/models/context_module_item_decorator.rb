ContextModule.class_eval do
  after_commit -> { PipelineService.publish(self, alias: 'module_item') }
end
