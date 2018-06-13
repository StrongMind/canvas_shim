# Since the shim doesn't know anything about the canvas things
# We use these shims as standins for objects that function
# quite nicely in Canvas, but not here in the shim.  Try removing one
# and running the tests to see where they are used
module Api
  module V1
    module Submission;end
    module Assignment;end
    module User
      def enrollment_json(*)
      end
    end
  end
end

class Enrollment
  def id;1;end

  def changes
  end

  def root_account
    Struct.new(:id).new(1)
  end
end

class Account
  def self.default
    Struct.new(:account_users).new(
      [
        Struct.new(:role, :user).new(
          Struct.new(:name).new('AccountAdmin'),
          'user'
        )
      ]
    )
  end
end


module Delayed
  module Job
    def self.enqueue(job)
      job.perform
    end
  end
end
