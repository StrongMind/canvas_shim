module PipelineService
  module V2
    module Nouns
      class CourseProgress
        def initialize object:
          @noun = object
        end

        def call
          @payload = Builders::CourseProgressJSONBuilder.call(@noun) || {}
        end

        def self.additional_identifier_fields
          [
            Identifier.new(Proc.new {|ar_model| [:course_id, ar_model.course_id]}),
            Identifier.new(Proc.new {|ar_model| [:user_id, ar_model.user_id]})
          ]
        end 
      end
    end
  end
end