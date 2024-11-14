module BasicLTI
  module BasicOutcomes
    class LtiResponse
      def create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)
        if @submission.present?
          @submission.score = new_score
          @submission.save
        else
          Submission.create(
            score: new_score,
            user: user,
            assignment: assignment
          )
        end
      end

      def handle_replaceResult(_tool, _course, assignment, user) end
    end
  end
end
