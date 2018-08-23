module SettingsService
  module Commands
    class UpdateSettings
      def initialize id:, setting:, value:, object:
        @id = id
        @setting = setting
        @value = value
        @object = object
      end

      def call
        object.create_table
        object.put(id: @id, setting: @setting, value: @value)
      end

      private

      def object
        case @object
        when 'assignment'
          SettingsService::Assignment
        when 'user'
          SettingsService::User
        when 'enrollment'
          SettingsService::Enrollment
        when 'student_assignment'
          SettingsService::StudentAssignment
        when 'school'
          SettingsService::School
        else
          raise "Unrecognized Object: #{@object}"
        end
      end
    end
  end
end
