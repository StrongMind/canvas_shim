module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :changes, :noun_class, :additional_identifiers
      
      def initialize(object)
        @id = object.id
        @noun_class = object.class
        @changes = object.changes
        @state = object.try(:state)
        @destroyed = status == :deleted || object.try(:workflow_state) == 'deleted'
        @additional_identifiers = get_additional_identifiers(object)
      end

      def destroyed?
        @destroyed
      end

      def status 
        return 'deleted' if destroyed?
        return if @state.nil?
        @state.to_s
      end

      def name
        short_class_name.underscore
      end

      def serializer
          case short_class_name
          when /Enrollment/
            PipelineService::Serializers::Enrollment
          else
            begin
              "PipelineService::Serializers::#{short_class_name}".constantize
            rescue
              nil
            end
          end
      end

      private

      def short_class_name
        @noun_class.to_s.split('::').last
      end

      def get_additional_identifiers(object)
        return {} unless serializer.try(:additional_identifier_fields)
        Helpers::AdditionalIdentifiers.call(
          instance: object,
          fields: serializer.additional_identifier_fields
        ) 
      end
    end
  end
end