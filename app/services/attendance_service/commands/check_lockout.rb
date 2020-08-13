module AttendanceService
  module Commands
    class CheckLockout
      def initialize(user:)
        @user = user
        @auth = ENV['ATTENDANCE_API_KEY_V2']
      end

      def call
        return false unless checkable?
        !!has_lockouts?
      end

      private
      attr_reader :user, :auth

      def checkable?
        auth && user && attendance_root && partner_name
      end
      
      def partner_name
        @partner_name ||= SettingsService.get_settings(object: 'user', id: user.id)["partner_name"]
      end

      def attendance_root
        @attendance_root ||= SettingsService.get_settings(object: 'school', id: user.id)["attendance_root"]
      end

      def integration_ids
        user.pseudonyms.active.select(&:identity_pseudonym?).map(&:integration_id)
      end

      def full_url(integration_id)
        "#{attendance_root}/#{partner_name}/Accounts/#{integration_id}/Attendance/Status"
      end

      def locked_out?(integration_id)
        HTTParty.post(
          full_url(integration_id), headers: { "CanvasAuth" => auth }
        ).parsed_response.try(:fetch, "isLockedOut", false)
      end

      def has_lockouts?
        integration_ids.any? { |integration_id| locked_out?(integration_id) }
      end
    end
  end
end