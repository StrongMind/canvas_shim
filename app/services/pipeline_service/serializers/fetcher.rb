module PipelineService
  module Serializers
    module Fetcher
      # Will fetch a serializer with the same name as the object parameter.
      # Raises a name error if the serializer doesn't exist.
      # Maps any object with a class containing 'enrollment' to the enrollment serializer
      def self.fetch(object:)
        case object.class.to_s
        when /Enrollment/
          # Publish all polymorphic class names like "TeacherEnrollment", etc as
          # "Enrollment"
          PipelineService::Serializers::Enrollment
        when /PipelineService::Helpers::DeletedNoun/
          "PipelineService::Serializers::#{object.name.to_s}".constantize
        when /PipelineService::Nouns::UnitGrades/
          PipelineService::Serializers::UnitGrades
        else
          "PipelineService::Serializers::#{object.class.to_s}".constantize
        end
      end
    end
  end
end
