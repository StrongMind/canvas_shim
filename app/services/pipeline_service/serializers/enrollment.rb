module PipelineService
  # This ugly thing lets us call the canvas user api
  module Serializers
    class Enrollment
      include ::Api::V1::User
      include BaseMethods
      
      attr_accessor :services_enabled, :context, :current_user, :params, :request

      def service_enabled?(service); @services_enabled.include? service; end

      def avatar_image_url(*args); "avatar_image_url(#{args.first})"; end

      def course_student_grades_url(course_id, user_id); ""; end

      def course_user_url(course_id, user_id); ""; end

      def initialize(object:)
        @domain_root_account = ::Account.default
        @params = {}
        @request = OpenStruct.new
        @object = object
        @admin = PipelineService::Account.account_admin
      end

      def call
        enrollment_json(@object, @admin, {})
      end
    end
  end
end
