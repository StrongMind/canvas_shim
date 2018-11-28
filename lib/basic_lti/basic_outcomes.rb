module BasicLTI
  module BasicOutcomes
    class LtiResponse
      alias_method :original_create_homework_submission, :create_homework_submission

      def create_homework_submission
        puts 'monkey_patch'
        original_create_homework_submission
      end

      def frog
        puts 'new frog!'
        orig_frog
      end
    end
  end
end
