module SpecialProgramsService
  module Commands
    class GetPrograms
      def initialize(user:)
        @user = user
        @special_programs = []
      end

      def call
        return special_programs unless user && partner_name && user_uuid
        response = HTTParty.get(programs_url, { 'Authorization': "Bearer #{user.access_token}" })

        response.parsed_response.each do |special_program|
          if program_applicable?(special_program)
            special_programs << special_program.dig("programReference", "programName")
          end
        end

        special_programs
      end

      private
      attr_reader :user, :special_programs

      def program_applicable?(program)
        begin_date, end_date = program["beginDate"], program["endDate"]
        parsed_begin_date, parsed_end_date = DateTime.parse(begin_date), DateTime.parse(end_date)
        now = DateTime.current
      
        if !begin_date && !end_date
          return true
        elsif !end_date
          return true if begin_date < now
        elsif !begin_date
          return true if end_date > now
        else
          return true if Date.today.between?(begin_date, end_date)
        end

        false
      end

      def partner_name
        @partner_name ||= SettingsService.get_settings(object: :user, id: user.id)["partner_name"]
      end

      def id_mapper_url
        %w(
          "#{IdentifierMapperService::SecretManager.get_secret['API_ENDPOINT']}"
          "/api/v1/pairs/strongmind.guid://com.instructure.canvas.users"
          "/#{partner_name}/#{user.id}"
        ).join
      end

      def user_uuid
        @user_uuid ||= IdentifierMapperService::Client.instance.send(
          :get, full_url).payload.dig("com.strongmind.user.id", partner_name)
      end

      def programs_url
        "https://api.platform.strongmind.com/ed-fi/studentProgramAssociations?studentUniqueId=#{user_uuid}"
      end
    end
  end
end