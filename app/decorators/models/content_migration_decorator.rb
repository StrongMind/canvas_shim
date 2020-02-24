ContentMigration.class_eval do
  after_save { PipelineService::V2.publish(self) }
  after_save -> { RequirementsService.set_third_party_requirements(course: context) }, if: :non_strongmind_cartridge?

  def non_strongmind_cartridge?
    imported? && Rails.cache.read("#{context_id}_vendor") != 'StrongMind'
  end
end