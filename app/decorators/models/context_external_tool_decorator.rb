ContextExternalTool.class_eval do
  def is_oauth_lti_domain?
    (SettingsService.global_settings["oauth_lti_domains"] || '').split(",").any? do |setting_domain|
      self.domain.include?(setting_domain)
    end
  end

  def set_setting_oauth_to_false
    self.settings["oauth_compliant"] = "false"
    save
  end
end