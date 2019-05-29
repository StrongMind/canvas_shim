module PipelineService
    module Nouns
      class CourseProgress < PipelineService::Models::Noun
        attr_reader :course_id, :user_id, :id
        def initialize(context_module_progression)
          @course_id = context_module_progression.context_module.context.id
          @user_id = context_module_progression.user.id
          @id = @course_id
          super
        end 

        def name
          'course_progress'
        end

        def serializer
          PipelineService::Serializers::CourseProgress
        end

        def self.primary_key
          'id'
        end
      end
    end
  end
