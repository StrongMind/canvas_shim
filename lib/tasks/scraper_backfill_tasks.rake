namespace :canvas_shim do
  namespace :pipeline do
    task :backfill_discussion_topic => :environment do
      DiscussionTopic.find_each do |model|
        PipelineService.publish model
      end
    end

    task :backfill_content_tag => :environment do
      ContentTag.find_each do |model|
        PipelineService::V2.publish model
      end
    end

    task :backfill_context_module do
      ContextModule.find_each do |model|
        PipelineService.publish(model, alias: 'module')
      end
    end

    task :backfill_context_module_item => :environment do
      ContextModuleItem.find_each do |model|
        after_commit -> { PipelineService.publish(model, alias: 'module_item') }
      end
    end

    task :assignment_group => :environment do
      AssignmentGroup.find_each do |model|
        PipelineService.publish(model)
      end
    end

    task :user => :environment do
      User.find_each do |model|
        PipelineService::V2.publish(model)
      end
    end
  end
end