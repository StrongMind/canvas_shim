module PipelineService
  module Nouns
    class Base
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

      def as_json
        builder.new(object: self).call
      end

      def self.build(ar_object)
        "PipelineService::Nouns::#{ar_object.class.to_s}"
          .constantize
          .new(ar_object)
      end

      private

      def short_class_name
        @noun_class.to_s.split('::').last
      end

      def builder
      end

      def get_additional_identifiers(object)
        return unless builder
        return {} unless self.class::ADDITIONAL_IDENTIFIER_FIELDS
        Helpers::AdditionalIdentifiers.call(
          instance: object,
          fields: self.class::ADDITIONAL_IDENTIFIER_FIELDS
        ) 
      end
    end
  end
end