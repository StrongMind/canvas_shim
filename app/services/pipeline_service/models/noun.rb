module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :changes, :noun_class
      
      def initialize(object)
        @id = object.id
        @noun_class = object.class
        @changes = object.changes
        @destroyed = object.try(:state) == :deleted || object.try(:workflow_state) == 'deleted' || object.try(:destroyed?)
      end

      def destroyed?
        @destroyed
      end

      def name
        short_class_name.underscore
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
        @noun_class.to_s.split('::').last
      end
    end
  end
end