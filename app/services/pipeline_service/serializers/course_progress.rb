module PipelineService
    module Serializers
      class CourseProgress
        def initialize object:
          @noun = object
        end
  
        def call
          @payload = Builders::CourseProgressJSONBuilder.call(@noun) || {}
        end

        
        # def self.additional_identifier_fields
        #   [
        #     Models::Identifier.new(:course_id), 
        #     Models::Identifier.new(:user_id)
        #   ]
        # end
        
      end
    end
  end
  

