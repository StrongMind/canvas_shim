module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :object, :changes
      
      def initialize(object)
        @id = object.id
        @name = object.class.to_s
        @changes = object.changes
        @destroyed = object.try(:state) == :deleted || object.try(:workflow_state) == 'deleted' || object.try(:destroyed?)
      end

      def destroyed?
        @destroyed
      end

      def noun_class
        name.constantize
      end

      def serializer
          case short_class_name
          when /Enrollment/
            PipelineService::Serializers::Enrollment
          else
            "PipelineService::Serializers::#{short_class_name}".constantize
          end
      end

      private

      def short_class_name
        name.split('::').last
      end
    end
  end
end