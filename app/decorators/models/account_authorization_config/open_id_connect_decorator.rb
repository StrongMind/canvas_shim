AccountAuthorizationConfig::OpenIDConnect.class_eval do
  def admin_role?(token)
    return unless roles(token)
    setting = SettingsService.global_settings["admin_roles"] || ""
    setting.split(",").any? { |role| roles(token).include?(role) }
  end

  def identity_email_address(token)
    parsed_claims = claims(token)
    key = parsed_claims.keys.find { |key| key.split("/").last == "emailaddress" }
    parsed_claims[key]
  end

  private

  def roles(token)
    claims(token)["role"]
  end
end