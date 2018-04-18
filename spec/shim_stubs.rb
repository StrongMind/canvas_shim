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

class DesignerEnrollment < Enrollment;end
class ObserverEnrollment < Enrollment;end
class StudentEnrollment < Enrollment;end
class TeacherEnrollment < Enrollment;end
class Submission;end
class User;end

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
