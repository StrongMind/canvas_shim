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

      def self.list_from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |parsed|
          return parsed.map do |attributes|
            new(
              teacher_id: attributes[:teacher_id],
              student_id: attributes[:student_id],
              assignment_id: attributes[:assignment_id]  
            )
          end
        end
      end

      def self.from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |parsed|
          return new(
            teacher_id: parsed[:teacher_id],
            student_id: parsed[:student_id],
            assignment_id: parsed[:assignment_id]
          )
        end
      end
    end
  end
end