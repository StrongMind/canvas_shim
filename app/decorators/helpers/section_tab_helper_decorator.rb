SectionTabHelper.class_eval do
  def strongmind_available_section_tabs(context)
    instructure_available_section_tabs(context).uniq
  end

  alias_method :instructure_available_section_tabs, :available_section_tabs
  alias_method :available_section_tabs, :strongmind_available_section_tabs
end