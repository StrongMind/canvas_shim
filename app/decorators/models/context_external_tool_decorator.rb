ContextExternalTool.class_eval do
  before_create :copy_account_config?

  def copy_account_config?
    if context_type == "Course" && [consumer_key, shared_secret].all?(&"fake".method(:==))
      account_tool = Account.default.context_external_tools.find_by(domain: domain)
      if account_tool
        assign_attributes(
          consumer_key: account_tool.consumer_key,
          shared_secret: account_tool.shared_secret
        )
      end
    end
  end

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