module AlertsService
  module Alerts
    class MaxAttemptsReached
      attr_accessor :teacher_id, :student_id, :assignment_id, :type
      
      def initialize(teacher_id:, student_id:, assignment_id:)
        @teacher_id = teacher_id
        @student_id = student_id
        @assignment_id = assignment_id
        @type = 'max_attempts_reached'
      end

      def as_json
        {
          teacher_id: teacher_id,
          student_id: student_id,
          assignment_id: assignment_id,
          type: type
        }
      end

      def self.from_json(json)
        parsed = JSON.parse(json, symbolize_names: true)
        new(
          teacher_id: parsed[:teacher_id],
          student_id: parsed[:student_id],
          assignment_id: parsed[:assignment_id]
        )
      end
    end
  end
end