# "id": 2212,
#             "user_id": 607,
#             "course_id": 502,
#             "type": "StudentEnrollment",
#             "created_at": "2019-03-13T22:41:30Z",
#             "updated_at": "2019-03-13T22:41:30Z",
#             "associated_user_id": null,
#             "start_at": null,
#             "end_at": null,
#             "course_section_id": 856,
#             "root_account_id": 1,
#             "limit_privileges_to_course_section": false,
#             "enrollment_state": "invited",
#             "role": "StudentEnrollment",
#             "role_id": 3,
#             "last_activity_at": null,
#             "total_activity_time": 0,
#             "sis_import_id": null,
#             "grades": {
#                 "html_url": "",
#                 "current_score": 0,
#                 "current_grade": null,
#                 "final_score": 0,
#                 "final_grade": null
#             },
#             "html_url": ""
#         }

module PipelineService
  # This ugly thing lets us call the canvas user api
  module Serializers
    class Enrollment
      include ::Api::V1::User
      include BaseMethods
      GRADE_TYPES = ['current_score', 'current_grade', 'final_score', 'final_grade']

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
        get_grades
        default_grades_to_zero
        @json.merge('grades' => @defaulted_grades)
      end
      
      private

      def get_json
        @json = enrollment_json(@enrollment, @admin, {})
      end

      def get_grades
        @grades = @json['grades'].clone
      end

      def default_grades_to_zero
        @defaulted_grades = 
          @grades.merge(
            GRADE_TYPES.map { |name| [name, (@grades[name] || 0)] }.to_h
          )
      end
    end
  end
end
