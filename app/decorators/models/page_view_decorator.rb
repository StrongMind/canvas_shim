PageView.class_eval do
  after_commit :publish_to_pipeline

  def publish_to_pipeline
    return unless SettingsService.get_settings(object: :school, id: 1)['publish_page_views']
    PipelineService.publish self
  end

end
