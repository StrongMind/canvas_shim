Pseudonym.class_eval do
  after_commit -> { PipelineService::V2.publish self }
  after_save :update_identity_mapper?, if: :integration_id_changed?

  def update_identity_mapper?
    self.send_later_if_production(:update_identity_mapper)
  end

  def update_identity_mapper
    return unless identity_integration_regex.match(integration_id) && user.identity_enabled && confirm_user.success?
    IdentifierMapperService::Client.post_canvas_user_id(user_id, integration_id)
  end

  def get_identity_username?
    self.unique_id = confirm_user.try(:fetch, "username", nil)
  end

  private

  def identity_integration_regex
    /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/
  end

  def confirm_user
    HTTParty.get(
      "https://#{user.identity_domain}/api/accounts/#{integration_id}",
      :headers => {
        'Authorization' => "Bearer #{user.access_token}"
      })
  end
end
