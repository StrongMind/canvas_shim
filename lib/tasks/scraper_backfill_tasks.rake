namespace :canvas_shim do
  namespace :pipeline do
    task :backfill_course_progress => :environment do
      ContextModuleProgression.find_each do |context_module_progression|
        PipelineService.publish(PipelineService::Nouns::CourseProgress.new(context_module_progression)) 
      end
    end

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
  end
end