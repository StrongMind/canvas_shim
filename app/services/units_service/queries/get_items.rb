module UnitsService
  module Queries
    class GetItems
      def initialize(course:)
        @course = course
        @context_modules = @course.context_modules
      end

      def query
        result = {}

        @context_modules.each do |context_module|
          result[context_module] =
            context_module.content_tags.select do |ct|
              ct.content.present? &&
              (ct.content.respond_to?(:submissions) || ct.content.respond_to?(:quiz_submissions)|| ct.content.try(:assignment).respond_to?(:submissions)) &&
              ['published', 'active'].include?(ct.content.try(:workflow_state)) || ct.content.try(:published?)
            end
        end
        result
      end
    end
  end
end
