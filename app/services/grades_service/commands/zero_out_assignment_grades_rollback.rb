module GradesService
  module Commands
    class ZeroOutAssignmentGradesRollback
      def call!
        SettingsService.query('zero_grader_audit')
      end
    end
  end
end
