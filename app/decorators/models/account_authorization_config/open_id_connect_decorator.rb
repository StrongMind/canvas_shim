AccountAuthorizationConfig::OpenIDConnect.class_eval do
  def aad_account?(token)
    return aad_id(token)
  end

  def identity_email_address(token)
    parsed_claims = claims(token)
    key = parsed_claims.keys.find { |key| key.split("/").last == "emailaddress" }
    parsed_claims[key]
  end

  private

  def aad_id(token)
    claims(token)["AADId"]
  end
end
