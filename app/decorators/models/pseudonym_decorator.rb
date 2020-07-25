Pseudonym.class_eval do
  after_commit -> { PipelineService::V2.publish self }
  after_save :update_identity_mapper?, if: :integration_id_changed?

  def update_identity_mapper?
    self.send_later_if_production(:update_identity_mapper)
  end

  def update_identity_mapper
    return unless identity_integration_regex.match(integration_id) && user.identity_enabled && confirm_user
    IdentifierMapperService::Client.post_canvas_user_id(user_id, integration_id, all_sis_ids)
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
      }).success?
  end

  def all_sis_ids
    user.pseudonyms.pluck(:sis_user_id).compact
  end
end
