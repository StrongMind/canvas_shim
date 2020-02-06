PageView.class_eval do
  after_commit :publish_to_pipeline
  after_save :update_last_online

  def publish_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['publish_page_views']
    PipelineService::V2.publish self
  end

  def update_last_online
    SettingsService.update_settings(
      object: 'user',
      id: self.real_user_id,
      setting: 'last_access_time',
      value: self.updated_at.utc.to_s
    )
  end


end
