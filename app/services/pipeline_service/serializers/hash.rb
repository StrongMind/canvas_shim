module PipelineService
  module Serializers
    class Hash
      def initialize(object:)
        @object = object
      end

      # This is only enrollments
      def call
        Serializers::Enrollment.new(
          object: ::Enrollment.find(object[:id])
        ).call
      end

      private

      attr_reader :object
    end
  end
end
