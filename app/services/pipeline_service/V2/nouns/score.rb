module PipelineService
  module V2
    module Nouns
      class Score < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end
 
        def call
          "{
            \"oneroster_result\": {
                \"sourcedId\": \"<sourcedid of this grade>\",
                \"status\": \"active | inactive | tobedeleted\",
                \"dateLastModified\": \"<date this result was last modified>\",
                \"lineitem\": {
                    \"href\": \"<href to this lineitem>\",
                    \"sourcedId\": \"<sourcedId of this lineitem>\",
                    \"type\": \"lineitem\"
                },

                \"student\": {
                    \"href\": \"<href to this student>\",
                    \"sourcedId\": \"<sourcedId of this student>\",
                    \"type\": \"user\"

                },

                \"score\": \"<score of this grade>\",
                \"resultstatus\": \"not submitted | submitted | partially graded | fully graded | exempt\",
                \"date\": \"<date that this grade was assigned>\",
                \"comment\": \"<a comment to accompany the score>\"
            }
          }"
        end
      end
    end
  end
end
