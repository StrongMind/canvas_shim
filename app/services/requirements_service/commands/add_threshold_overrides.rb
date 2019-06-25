module RequirementsService
  module Commands
    class AddThresholdOverrides
      def initialize(context_module:, requirements:)
        @context_module = context_module
        @requirements = requirements
      end

      private
      attr_reader :context_module, :requirements
    end
  end
end