module Api
  module V1
    module Submission
    end
    module User
      def enrollment_json(one, two, three)
      end
    end
  end
end

class Enrollment
  def id;1;end
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
