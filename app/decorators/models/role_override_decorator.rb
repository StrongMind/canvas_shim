RoleOverride.class_eval do
  Permissions.register({
    :custom_placement => {
      :label => lambda { "Apply Custom Placement to Courses" },
      :available_to => [
        'TaEnrollment',
        'TeacherEnrollment',
        'AccountAdmin',
      ],
      :true_for => [
        'AccountAdmin',
      ]
    },
    :delete_inbox_messages => {
      :label => lambda { "Delete inbox messages" },
      :available_to => [
        'StudentEnrollment',
        'TaEnrollment',
        'TeacherEnrollment',
        'DesignerEnrollment',
        'TeacherlessStudentEnrollment',
        'ObserverEnrollment',
        'AccountAdmin',
        'AccountMembership'
      ],
      :true_for => [
        'StudentEnrollment',
        'TaEnrollment',
        'TeacherEnrollment',
        'DesignerEnrollment',
        'TeacherlessStudentEnrollment',
        'ObserverEnrollment',
        'AccountAdmin',
        'AccountMembership'
      ]
    }
  })
end