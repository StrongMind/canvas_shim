module BasicLTI
  module BasicOutcomes
    class LtiResponse
      def create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)
      end
    end
  end
end
require File.expand_path('../../lib/basic_lti/basic_outcomes', CanvasShim::Engine.called_from)
