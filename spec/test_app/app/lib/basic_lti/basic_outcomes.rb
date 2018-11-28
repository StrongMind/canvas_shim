module BasicLTI
  module BasicOutcomes
    class LtiResponse
      def create_homework_submission
        puts 'create_homework'
      end
    end
  end
end
require File.expand_path('../../lib/basic_lti/basic_outcomes', CanvasShim::Engine.called_from)
