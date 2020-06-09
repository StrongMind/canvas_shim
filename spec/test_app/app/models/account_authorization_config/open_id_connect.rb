class AccountAuthorizationConfig::OpenIDConnect
  def claims(token=nil)
    {
      "nbf"=>1591399722, "exp"=>1591400022,
      "iss"=>"https://devlogin.strongmind.com",
      "aud"=>"NewIdSandbox", "iat"=>1591399722, 
      "at_hash"=>"YWwOH8vy5WcynD6QF8440A", 
      "s_hash"=>"gG58Fr8pf7Y_JhXsvURmqA", 
      "sid"=>"mFwSE_a19izZQpJ-IGMSIw",
      "sub"=>"d98029ea-22d2-49a0-b8e8-a286224fd6e8",
      "auth_time"=>1591399722, "idp"=>"local", "amr"=>["pwd"],
      "role"=>["sgi-developers", "SGA_vsts_ro", "tesla"], 
      "AADId"=>"a1cc8072-8126-4381-9541-8eac5505faac", 
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"=>"d98029ea-22d2-49a0-b8e8-a286224fd6e8",
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"=>"Andy.Rosenberg@strongmind.com",
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"=>"Andy.Rosenberg@strongmind.com",
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"=>"Andy",
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"=>"Rosenberg",
      "TimeZone"=>"US Mountain Standard Time"
    }
  end
end