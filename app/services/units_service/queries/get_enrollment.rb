module UnitsService
  module Queries
    module GetEnrollment
      def self.query(course:, user:)
        Enrollment.find_by(course: course, user: user)
      end
    end
  end
end
