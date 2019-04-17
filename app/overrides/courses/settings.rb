Deface::Override.new(
  :virtual_path => "courses/settings",
  :name => "course_credit_recovery",
  :insert_before => "#notenough tr",
  :partial => "courses/credit_recovery"
)
