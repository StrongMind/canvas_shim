Pseudonym.class_eval do
  after_commit -> { PipelineService::V2.publish self }
  after_save :update_identity_mapper?, if: :integration_id_changed?
  validates :integration_id, uniqueness: true, :allow_blank => true

  def update_identity_mapper?
    self.send_later_if_production(:update_identity_mapper)
  end

  def update_identity_mapper
    return unless identity_pseudonym? && user.identity_enabled && confirmed_in_identity?
    IdentifierMapperService::Client.post_canvas_user_id(user_id, integration_id, all_sis_ids)
  end

  def get_identity_username?
    identity_request = confirm_user
    unique_id = identity_request.try(:fetch, "username", nil)
    if unique_id
      self.unique_id = unique_id.parameterize(separator: " ", preserve_case: true)
    else
      self.unique_id = nil
      errors.add(:unique_id,
        "Incorrect Identity. Identity Server Responded with #{identity_request.code}."
      )
    end
  end

  def identity_pseudonym?
    identity_integration_regex.match(integration_id)
  end

  def confirmed_in_identity?
    confirm_user.success?
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

  def all_sis_ids
    user.pseudonyms.pluck(:sis_user_id).compact
  end
end
