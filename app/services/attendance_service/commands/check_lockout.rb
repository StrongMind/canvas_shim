module AttendanceService
  module Commands
    class CheckLockout
      def initialize(pseudonym:)
        @pseudonym = pseudonym
        @user = @pseudonym.try(:user)
        @auth = ENV['ATTENDANCE_API_KEY_V2']
      end

      def call
        return false unless checkable?
        !!locked_out?
      end

      private
      attr_reader :pseudonym, :user, :auth

      def checkable?
        auth && pseudonym && user && attendance_root && partner_name
      end
      
      def partner_name
        @partner_name ||= SettingsService.get_settings(object: 'user', id: user.id)["partner_name"]
      end

      def attendance_root
        @attendance_root ||= SettingsService.get_settings(object: 'school', id: user.id)["attendance_root"]
      end

      def integration_id
        @integration_id ||= pseudonym.integration_id
      end

      def full_url
        "#{attendance_root}/#{partner_name}/Accounts/#{integration_id}/Attendance/Status"
      end

      def locked_out?
        HTTParty.post(full_url, headers: { "CanvasAuth" => auth }).try(:fetch, "isLockedOut", false)
      end
    end
  end
end