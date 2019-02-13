module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :object, :changes
      
      def initialize(object)
        @id = object.id
        @name = object.class.to_s
        @changes = object.changes
        @destroyed = object.try(:state) == :deleted || object.try(:workflow_state) == 'deleted' || object.destroyed?
      end

      def destroyed?
        @destroyed
      end

      def noun_class
        name.constantize
      end

      def serializer
          case name.split('::').last
          when /Enrollment/
            PipelineService::Serializers::Enrollment
          else
            "PipelineService::Serializers::#{name}".constantize
          end
      end
    end
  end
end