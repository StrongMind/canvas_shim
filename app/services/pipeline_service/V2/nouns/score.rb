module PipelineService
  module V2
    module Nouns
      class Score < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end
 

        def result_status
          statuses =  {
            "active" => "partially graded",
            "completed" => "fully graded"
          }
          #guess as to how we want to determine if a score object is fully graded or not
          statuses[@ar_object.enrollment.workflow_state] || "not found"
        end

        def date_of_last_user_submission_update
          Time.now #fix this soon
        end

        def call
          {
            oneroster_result: {
                #guess as to sourced id
                sourcedId: "com.instructure.canvas.scores.#{@ar_object.id}",
                #one of active | inactive | tobedeleted
                status: "active",
                dateLastModified: @ar_object.updated_at,
                lineitem: {
                  href: "<href to this lineitem>",
                  sourcedId: "com.instructure.canvas.courses.#{@ar_objec.enrollment.course.id}",
                  type: "lineitem"
                },
                student: {
                    href: "<href to this student>",
                    sourcedId: "com.instructure.canvas.users.#{@ar_object.enrollment.user.id}",
                    type: "user"
                },
                score: @ar_object.score,
                resultstatus: result_status,
                date: "{#@ar_object.enrollment.concluded_at} || date_of_last_user_submission_update",
            }
          }
        end
      end
    end
  end
end
