class ContentMigration < ActiveRecord::Base
  after_save { PipelineService::V2.publish(self)}
end
