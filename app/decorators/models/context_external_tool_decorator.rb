ContextExternalTool.class_eval do
  def is_oauth_lti_domain?
    return false unless self.domain
    (SettingsService.global_settings["oauth_lti_domains"] || '').split(",").any? do |setting_domain|
      self.domain.downcase.include?(setting_domain.downcase)
    end
  end

  def set_setting_oauth_to_false
    self.settings["oauth_compliant"] = "false"
    save
  end
end