module BasicLTI
  module BasicOutcomes
    class LtiResponse
      alias_method :homework_submission_alias, :create_homework_submission

      def create_homework_submission(_tool, submission_hash, assignment, user, new_score, raw_score)
        homework_submission_alias(_tool, submission_hash, assignment, user, new_score, raw_score)

        if SettingsService.get_settings(object: :school, id: 1)['lti_keep_highest_score']
          update_submission_with_best_score
        end
      end

      private

      def update_submission_with_best_score
        return unless @submission
        best_score = @submission.score
        best_grade = @submission.grade
        versions = @submission.versions
        versions.each do |version|
          version_score = YAML.load(version.yaml).stringify_keys['score']
          if version_score.to_f > best_score.to_f
            best_score = version_score
            best_grade = YAML.load(version.yaml).stringify_keys['grade']
          end
        end

        @submission.update(score: best_score, grade: best_grade)
      end
    end
  end
end
