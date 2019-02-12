module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :object
      
      def initialize(object)
          @id = object.id
          @name = object.class.to_s.split('::').last
          @destroyed = object.try(:state) == :deleted || object.try(:workflow_state) == 'deleted' || object.destroyed?
      end

      def destroyed?
        @destroyed
      end

      def serializer
          case name
          when /Enrollment/
            PipelineService::Serializers::Enrollment
          else
            "PipelineService::Serializers::#{name}".constantize
          end
      end
    end
  end
end