module UnitsService
  module Queries
    class IsUnitExcused
      def initialize(unit_id:, student:)
        @student = student
        @unit = ContextModule.find(unit_id)
      end

      def query
        return false unless @unit && assignments.any?

        assignments.each do |item|
          subs = item.content.try(:submissions) ||
                item.content.try(:assignment).submissions
          return false unless subs.where(user_id: @student.id, excused: true).any?
        end

        true
      end

      def assignments
        @assignments ||= @unit.content_tags.select do |ct|
          ct.content.present? &&
          (ct.content.respond_to?(:submissions) || ct.content.try(:assignment).respond_to?(:submissions)) &&
          ['published', 'active'].include?(ct.content.workflow_state)
        end
      end
    end
  end
end
