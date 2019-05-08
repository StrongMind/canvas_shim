module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :changes, :noun_class, :additional_identifiers, :primary_key

      def initialize(object)
        @primary_key = object.class.primary_key
        @id = object.send(primary_key)
        @noun_class = object.class
        @changes = object.changes
        @workflow_state = object.try(:workflow_state)
        @object_is_destroyed = object.try(:destroyed?)
        @additional_identifiers = get_additional_identifiers(object)
      end

      def destroyed?
        @workflow_state == 'deleted' || @object_is_destroyed
      end

      def status
        return 'deleted' if destroyed?
        @workflow_state
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

      def fetch
        self.class.new(noun_class.find_by(id: id))
      end

      def valid?
        !additional_identifiers.values.any?(&:nil?)
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
