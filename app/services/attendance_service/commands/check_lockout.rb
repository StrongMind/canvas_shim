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
        auth && attendance_root && pseudonym && partner_name
      end

      def locked_out?
        return false if ENV.fetch('ATTENDANCE_LOCKOUT_DISABLED', false)
        # this is the trans.check user (https://login.strongmind.com/Profiles/86d3b246-4296-4507-b56f-7c7fe0431cc9)
        # we don't need to check this user's lockout status and make unnecessary API calls
        # it causes too much noise in Sentry https://strongmind-4j.sentry.io/issues/6360033685/
        return false if integration_id == "86d3b246-4296-4507-b56f-7c7fe0431cc9"

        response = HTTParty.get(full_url, headers: { "CanvasAuth" => auth })

        case response.code
        when 200..299
          return response['isLockedOut']
        when 401, 403
          raise UnauthorizedError, "Unauthorized access to attendance service"
        when 404
          raise NotFoundError, "Resource not found in attendance service"
        when 500..599
          raise ServiceError, "Attendance service error: #{response.code}"
        else
          raise UnknownError, "Unexpected response from attendance service: #{response.code}"
        end
      end

      def partner_name
        @partner_name ||= begin
          name = SettingsService.get_settings(object: 'user', id: user.id)["partner_name"] || ENV['PARTNER_NAME']
          raise MissingPartnerError, "No partner name found for user #{user.id}" unless name
          name
        end
      end

      def integration_id
        @integration_id ||= pseudonym.integration_id
      end

      def full_url
        "#{attendance_root}/#{partner_name}/Accounts/#{integration_id}/Attendance/Status"
      end
    end
  end

  class UnauthorizedError < StandardError; end
  class NotFoundError < StandardError; end
  class ServiceError < StandardError; end
  class UnknownError < StandardError; end
  class MissingPartnerError < StandardError; end
end
