require 'forwardable'
module SettingsService
  class StudentAssignmentRepository < Base
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :create_table, :get, :put
    end

    def initialize
      raise "missing canvas domain!" if SettingsService.canvas_domain.nil?
      @secret_key = ENV['S3_ACCESS_KEY']
      @id_key = ENV['S3_ACCESS_KEY_ID']
      Aws.config.update(
        region: 'us-west-2',
        credentials: creds
      )
    end

    def create_table(name:)
      begin
        self.class.dynamodb.create_table(table_params(name)).successful?
      rescue
      end
    end

    def get(table_name:, id:)
      assignment = ::Assignment.find(id[:assignment_id])
      migration_id = assignment.migration_id
      student_assignment_id = "#{migration_id}:#{id[:student_id]}"

      self.class.dynamodb.query(
        table_name: table_name,
        key_condition_expression: "#id = :id",
        expression_attribute_names: { "#id" => "id" },
        expression_attribute_values: { ":id" => student_assignment_id }
      ).items.inject({}) do |newhash, setting|
        newhash[setting['setting']] = setting['value']
        newhash
      end
    end

    def put(table_name:, id:, setting:, value:)
      return unless value == 'increment'


      assignment = ::Assignment.find(id[:assignment_id])
      return unless assignment.migration_id
      migration_id = assignment.migration_id
      student_assignment_id = "#{migration_id}:#{id[:student_id]}"


      value = SettingsService.get_settings(
        object: 'assignment',
        id: migration_id
      )["max_attempts"]

      return unless value

      student_attempts = SettingsService.get_settings(
        object: 'student_assignment',
        id: id
      )['max_attempts']

      value = student_attempts if student_attempts

      self.class.dynamodb.put_item(
        table_name: table_name,
        item: {
          id: student_assignment_id,
          setting: setting,
          value: value.to_i + 1
        }
      )
    end

    private

    def creds
      Aws::Credentials.new(@id_key, @secret_key)
    end

    def table_params(name)
      {
        table_name: name,
        key_schema: [
          { attribute_name: 'id', key_type: 'HASH' },
          { attribute_name: 'setting', key_type: 'RANGE'},
        ],
        attribute_definitions: [
            { attribute_name: 'id', attribute_type: 'S' },
            { attribute_name: 'setting', attribute_type: 'S' },
        ],
        provisioned_throughput: {
            read_capacity_units: 10,
            write_capacity_units: 10
        }
      }
    end

  end
end
