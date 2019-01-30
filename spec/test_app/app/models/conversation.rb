class Conversation < ActiveRecord::Base
  after_save { PipelineService.publish(self) }
end
