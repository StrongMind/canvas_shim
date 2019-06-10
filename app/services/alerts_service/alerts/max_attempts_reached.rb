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
      
      # Return a list of alerts from json
      def self.list_from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |parsed|
          return parsed.map do |attributes|
            from_payload_attributes(attributes)
          end
        end
      end

      # Return a single alert from json
      def self.from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |attributes|
          return from_payload_attributes(attributes)  
        end
      end

      # Return an instance by pulling the required attributes 
      # from a hash
      def self.from_payload_attributes(attributes)
        new(
          teacher_id: attributes[:teacher_id],
          student_id: attributes[:student_id],
          assignment_id: attributes[:assignment_id]
        )
      end
    end
  end
end