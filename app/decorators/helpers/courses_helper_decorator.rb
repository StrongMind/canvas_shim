CoursesHelper.class_eval do
  def present_sis_ids(stu_enr)
    joined_ids = stu_enr[3..-1].join(',')
    joined_ids.empty? ? "N/A" : joined_ids
  end
end