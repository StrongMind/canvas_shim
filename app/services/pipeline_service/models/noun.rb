module PipelineService
  module Models
    class Noun
      attr_reader :id, :name, :changes, :noun_class, :additional_identifiers, :primary_key

      def initialize(object, args={})
        @primary_key = object.class.primary_key
        @id = object.send(primary_key)
        @noun_class = object.class
        @changes = object.changes if object.respond_to?(:changes)
        @workflow_state = object.try(:workflow_state)
        @object_is_destroyed = object.try(:destroyed?)

        @additional_identifiers =
        if self.class == PipelineService::Models::Noun
          # Synthetic nouns dont wrap active record objects and have their own serializers
          # with additional identifiers
          get_additional_identifiers(object)
        else
          get_additional_identifiers(self)
        end
        @alias = args[:alias]
      end

      def destroyed?
        @workflow_state == 'deleted' || @object_is_destroyed
      end

      def status
        return 'deleted' if destroyed?
        @workflow_state
      end

      def name
        send(:alias) || short_class_name.underscore
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
        # returns true if additional_identifiers are nil
        return true if additional_identifiers.nil?
        # returns false if any of the values in the additional_identifiers values are nil
        !additional_identifiers.values.any?(&:nil?)
      end

      private

      attr_reader :alias

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
