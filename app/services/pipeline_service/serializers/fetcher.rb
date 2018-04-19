module PipelineService
  module Serializers
    module Fetcher
      def self.fetch(object: )
        case object
        when Enrollment, DesignerEnrollment, ObserverEnrollment, StudentEnrollment, TeacherEnrollment
          PipelineService::Serializers::Enrollment
        when Submission
          PipelineService::Serializers::Submission
        when User
          PipelineService::Serializers::User
        else
          raise NameError.new("Could not find the serializer for #{object}")
        end
      end
    end
  end
end
