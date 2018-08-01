module CanvasShim
  module AuthenticationMethods
    def load_user
      original_method

      sis_id = @current_user && @current_user.pseudonym && @current_user.pseudonym.sis_user_id
      return unless sis_id
      begin
        lock_out = HTTParty.get(
          "https://flms.flipswitch.com/AttendanceTwo/IsLockedOut?schoolId=17&studentId=#{sis_id}",
          headers: { "CanvasAuth" => "98454055-2148-4F9B-A170-FD61562998CE" }
        ).body == 'true'

        redirect_to('https://flms.flipswitch.com') if lock_out
      end
    end
  end
end
