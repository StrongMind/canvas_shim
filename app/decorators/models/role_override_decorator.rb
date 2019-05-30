RoleOverride.class_eval do
  Permissions.register({
    :course_passing_thresholds => {
      :label => lambda { "Add, edit and delete course passing thresholds" },
      :available_to => [
        'TeacherEnrollment',
        'AccountAdmin'
      ],
      :true_for => [
        'TeacherEnrollment',
        'AccountAdmin'
      ]
    },
  })
end