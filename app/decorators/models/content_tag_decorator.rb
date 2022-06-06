ContentTag.class_eval do
  after_commit -> { PipelineService::V2.publish self }
  after_commit -> do
    return unless course
    puts "######################################################################"
    puts "######################################################################"
    puts "self: #{self.inspect}"
    puts "######################################################################"
    puts caller
    puts "######################################################################"
    puts "######################################################################"
    PipelineService.publish PipelineService::Nouns::ModuleItem.new(self)
  end
end
