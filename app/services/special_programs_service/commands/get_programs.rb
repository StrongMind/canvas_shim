module SpecialProgramsService
  module Commands
    class GetPrograms
      def initialize(user:)
        @user = user
        @special_programs = []
      end

      def call
        return special_programs unless user && partner_name && user_uuid && programs_domain
        response = HTTParty.get(programs_url, headers: {
          'Authorization': "Bearer #{user.access_token}"
        })

        if response.code == 200
          response.parsed_response.each do |special_program|
            if program_applicable?(special_program)
              special_programs << special_program.dig("programReference", "programName")
            end
          end
        end

        special_programs
      end

      private
      attr_reader :user, :special_programs

      def program_applicable?(program)
        begin_date, end_date = program["beginDate"], program["endDate"]
        begin_date = DateTime.parse(begin_date) if begin_date
        end_date = DateTime.parse(end_date) if end_date
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
        "#{IdentifierMapperService::SecretManager.get_secret['API_ENDPOINT']}" \
        "/api/v1/pairs/strongmind.guid://com.instructure.canvas.users" \
        "/#{partner_name}/#{user.id}"
      end

      def user_uuid
        @user_uuid ||= IdentifierMapperService::Client.instance.send(
          :get, id_mapper_url).payload.dig("com.strongmind.user.id", partner_name)
      end

      def programs_url
        "https://#{programs_domain}/ed-fi/v5.1.0/api/data/v3/ed-fi/studentProgramAssociations?studentUniqueId=#{user_uuid}"
      end

      def programs_domain
        SettingsService.get_settings(object: :school, id: 1)["programs_domain"]
      end
    end
  end
end