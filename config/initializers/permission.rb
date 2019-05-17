# canvas-lms proper, plugins, etc. call Permissions.register to add
# permissions to the system. all registrations must happen during app init;
# once the app is running (particularly, after the first call to
# Permissions.retrieve) the registry will be frozen and further registrations
# will be ignored.
#
# can take one permission or a hash of permissions
#


Permissions.register({
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
  },
})