ContentMigration.class_eval do
  after_save { PipelineService::V2.publish(self) }
  after_save :run_third_party_services, if: :non_strongmind_cartridge?
  after_save :set_min_thresholds_if_complete, if: Proc.new { |migration| migration.complete? && migration.workflow_state == 'imported' }


  def non_strongmind_cartridge?
    SettingsService.get_settings(object: :school, id: 1)['third_party_imports'] &&
    imported? && Rails.cache.read("#{context_id}_vendor") != 'StrongMind'
  end

  def run_third_party_services
    RequirementsService.set_third_party_requirements(course: context)
    RequirementsService.force_min_scores(course: context)
  end

  def set_min_thresholds_if_complete
    content_tags = ContentTag.where(context_id: self.context.id)

    content_tags.each do |tag|
      next unless assignment = tag.assignment
      threshold_type = assignment.passing_threshold_setting_name
      RequirementsService.add_unit_item_with_min_score(context_module: tag.context_module, content_tag: tag, threshold_type: threshold_type )
    end
  end
end
