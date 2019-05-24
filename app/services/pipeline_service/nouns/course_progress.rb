module PipelineService
    module Nouns
      class CourseProgress
        attr_reader :course_id, :user_id, :id
        def initialize(context_module_progression)
          @course_id = context_module_progression.context_module.context.id
          @user_id = context_module_progression.user.id
          @id = @course_id
        end

        def self.primary_key
          'id'
        end
      end
    end
  end
