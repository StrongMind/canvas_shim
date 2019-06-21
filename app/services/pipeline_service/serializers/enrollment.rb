module PipelineService
  # This ugly thing lets us call the canvas user api
  module Serializers
    class Enrollment
      include ::Api::V1::User
      include BaseMethods
      GRADE_TYPES = ['current_score', 'final_score']

      attr_accessor :services_enabled, :context, :current_user, :params, :request

      def self.additional_identifier_fields
        [
          Models::Identifier.new(:course_id),
          Models::Identifier.new(:user_id)
        ]
      end

      def account_admin
        account = ::Account.default.account_users.find do |account_user|
          account_user.role.name == 'AccountAdmin'
        end.try(:user)
      end

      def service_enabled?(service); @services_enabled.include? service; end

      def avatar_image_url(*args); "avatar_image_url(#{args.first})"; end

      def course_student_grades_url(course_id, user_id); ""; end

      def course_user_url(course_id, user_id); ""; end

      def initialize(object:)
        @domain_root_account = ::Account.default
        @params = {}
        @request = OpenStruct.new
        @object = object
        @enrollment = ::Enrollment.find(object.id)
        @admin = account_admin
      end

      def call
        get_json
        if @enrollment.is_a?(StudentEnrollment)
          get_grades
          set_nil_grades_to_zero
          @json.merge('grades' => @zeroed_grades)
        else
          @json
        end
      end
      
      private

      def get_json
        @json = enrollment_json(@enrollment, @admin, {})
      end

      def get_grades
        @grades = @json['grades'].clone
      end

      def set_nil_grades_to_zero
        @zeroed_grades = 
          @grades.merge(
            GRADE_TYPES.map { |name| [name, (@grades[name] || 0)] }.to_h
          )
      end
    end
  end
end
