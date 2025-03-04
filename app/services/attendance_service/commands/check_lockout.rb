module AttendanceService
  module Commands
    class CheckLockout
      def initialize(pseudonym:)
        @pseudonym = pseudonym
        @user = @pseudonym.try(:user)
        @auth = ENV['ATTENDANCE_API_KEY_V2']
        @attendance_root = ENV['ATTENDANCE_API_ROOT_V2']
      end

      def call
        return false unless checkable?
        !!locked_out?
      end

      private
      attr_reader :pseudonym, :user, :auth, :attendance_root

      def checkable?
        auth && attendance_root && pseudonym && user && partner_name
      end

      def partner_name
        @partner_name ||= SettingsService.get_settings(object: 'user', id: user.id)["partner_name"]
      end

      def integration_id
        @integration_id ||= pseudonym.integration_id
      end

      def full_url
        "#{attendance_root}/#{}/Accounts/#{integration_id}/Attendance/Status"
      end

      def locked_out?
        response = HTTParty.get(full_url, headers: { "CanvasAuth" => auth })
        
        case response.code
        when 200..299
          response.try(:fetch, "isLockedOut", false)
        when 401, 403
          raise AttendanceService::UnauthorizedError, "Unauthorized access to attendance service"
        when 404
          raise AttendanceService::NotFoundError, "Resource not found in attendance service"
        when 500..599
          raise AttendanceService::ServiceError, "Attendance service error: #{response.code}"
        else
          raise AttendanceService::UnknownError, "Unexpected response from attendance service: #{response.code}"
        end
      end
    end
  end

  class UnauthorizedError < StandardError; end
  class NotFoundError < StandardError; end
  class ServiceError < StandardError; end
  class UnknownError < StandardError; end
end
