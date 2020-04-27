ContextExternalTool.class_eval do
  def is_oauth_lti_domain?
    return false unless self.domain
    (SettingsService.global_settings["oauth_lti_domains"] || '').split(",").any? do |setting_domain|
      self.domain.downcase.include?(setting_domain.downcase)
    end
  end

  def is_oauth_noncompliant?
    SettingsService.get_settings(object: :school, id: 1)['third_party_imports'] &&
    !is_oauth_lti_domain?
  end
end