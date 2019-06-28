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
            :assignment_id => object.ar_model.user_id,
            :course_id => object.ar_model.user_id
          }
        else
          {}
        end
      end

    end
  end
end
