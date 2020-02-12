PageView.class_eval do
  after_commit :publish_to_pipeline
  after_save :update_last_online

  def publish_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['publish_page_views']
    PipelineService::V2.publish self
  end

  def update_last_online
    cache_key = "#{self.user_id}/last_access_time"
    Rails.cache.write(cache_key, Time.now.utc, :expires_in => 5.minutes)
  end


end
