module GradesService
  module Commands
    class ZeroOutAssignmentGradesRollback
      def call!(options={})
        load_audit(options)

        CSV.foreach('/tmp/zero_grader_rollback.csv') do |row|
          submission_id = row[0]
          orig_score = row[1]
          submission = Submission.find(submission_id)
          user = submission.user
          grader = GradesService::Account.account_admin
          submission = Submission.find(submission_id)
          assignment = submission.assignment

          if orig_score.present? && submission.score == 0 || submission.score.nil?
            puts "Setting submission #{submission.id} from #{submission.score} to #{orig_score or 'nil'}"
            begin
              puts "assignment.grade_student(#{user.id}, score: #{orig_score or 'nil'}, grader: 1)"
              assignment.grade_student(user, score: orig_score, grader: grader)
            rescue => e
              puts "Failed Setting submission #{submission.id} from #{submission.score} to #{orig_score or 'nil'}: #{e}"
            end
          end
        end
      end

      private

      def load_audit(options)
        s3 = Aws::S3::Client.new
        File.open('/tmp/zero_grader_rollback.csv', 'w') do |file|
          s3.get_object({ bucket: ENV['S3_BUCKET_NAME'], key: 'zero_grader/' + options[:log_file] }, target: file)
        end
      end
    end
  end
end
