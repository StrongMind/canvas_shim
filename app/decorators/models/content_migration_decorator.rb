ContentMigration.class_eval do
  after_save { PipelineService::V2.publish(self) }
  after_save :run_third_party_services, if: :non_strongmind_cartridge?

  def non_strongmind_cartridge?
    SettingsService.get_settings(object: :school, id: 1)['third_party_imports'] &&
    imported? && Rails.cache.read("#{context_id}_vendor") != 'StrongMind'
  end

  def update_oauth_settings?
    self.context.context_external_tools.each do |cet|
      cet.set_setting_oauth_to_false unless cet.is_oauth_lti_domain?
    end
  end

  def run_third_party_services
    RequirementsService.set_third_party_requirements(course: context)
    RequirementsService.force_min_scores(course: context)
    update_oauth_settings?
  end
end