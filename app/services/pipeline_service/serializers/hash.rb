module PipelineService
  module Serializers
    class Hash
      def initialize(object:)
        @object = object
      end

      def call
        object
      end

      private

      attr_reader :object
    end
  end
end
