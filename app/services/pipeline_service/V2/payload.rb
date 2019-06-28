module PipelineService
  module V2
    class Payload < Endpoints::Pipeline::MessageBuilder
      def log
        # Payload doesn't log
      end

      def additional_identifiers
        case object.noun_class.name
        when /Submission/
          {
            :assignment_id => object.ar_model.assignment.id,
            :course_id => object.ar_model.assignment.course.id
          }
        else
          {}
        end
      end

    end
  end
end
