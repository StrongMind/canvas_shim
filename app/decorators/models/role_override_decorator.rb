RoleOverride.class_eval do
  Permissions.register({
    :beer_truck => {
      :label => lambda { "Beer Truck" },
      :available_to => [
        'TaEnrollment',
        'TeacherEnrollment',
        'AccountAdmin',
        'AccountMembership'
      ],
      :true_for => [
        'AccountAdmin',
      ]
    }
  })
end