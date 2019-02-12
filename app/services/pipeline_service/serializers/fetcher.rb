module PipelineService
  module Serializers
    module Fetcher
      def self.fetch(object:)
        case object.class.to_s
        when /Enrollment/
          PipelineService::Serializers::Enrollment
        when /PipelineService::Models::Noun/
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
