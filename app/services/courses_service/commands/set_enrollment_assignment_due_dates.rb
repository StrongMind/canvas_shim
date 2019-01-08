module CoursesService
  module Commands
    class SetEnrollmentAssignmentDueDates
      def initialize(args = {})
         @args = args
         @enrollment = args[:enrollment]
      end

      def call
        @enrollment.update
      end
    end
  end
end
