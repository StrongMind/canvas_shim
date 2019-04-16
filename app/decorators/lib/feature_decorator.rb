Feature.class_eval do
  register(
    'hide_inbox' =>
    {
      display_name: -> { "Hide Inbox" },
      description: -> { "Hides the inbox." },
      applies_to: "RootAccount",
      state: "allowed",
      beta: false,
      development: false,
      use_settings_service: true
    },
    'zero_out_past_due' =>
    {
      display_name: -> { "Auto-grade past due assignments" },
      description: -> { "Automatically assign a grade of zero to past due assignments." },
      applies_to: "RootAccount",
      state: "allowed",
      beta: false,
      development: false,
      use_settings_service: true
    },
    'auto_due_dates' =>
    {
      display_name: -> { "Distribute due dates on import" },
      description: -> { "Distribute due dates evenly across the duration of the course" },
      applies_to: "RootAccount",
      state: "allowed",
      beta: false,
      development: false,
      use_settings_service: true
    },
    'prescriptive_credit_recovery' =>
    {
      display_name: -> { "Enable prescriptive credit recovery" },
      description: -> { "Allow students to bypass units based on pretest score." },
      applies_to: "RootAccount",
      state: "allowed",
      beta: false,
      development: false,
      use_settings_service: true
    }
  )
end