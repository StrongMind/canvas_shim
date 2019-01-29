class Message < ApplicationRecord
  after_save { PipelineService.publish(self) }
end
