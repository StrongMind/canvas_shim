ContextModulesController.class_eval do
  def strongmind_update
    @module = @context.context_modules.not_deleted.find(params[:id])
    add_overrides if authorized_action(@module, @current_user, :update)
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_add_item
    instructure_add_item
    return unless gradeable_tag_type? && threshold_set?
    add_threshold_to_module
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  private
  def gradeable_tag_type?
    %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@tag.content_type)
  end

  def add_threshold_to_module
    @module.completion_requirements << {:id => @tag.id, :type => "min_score", :min_score => score_threshold}
    @module.update_column(:completion_requirements, @module.completion_requirements)
  end

  def add_overrides
    @changed_reqs = []
    context_module_params[:completion_requirements].each do |k, v|
      requirement = @module.completion_requirements.find {|req| req[:id] == k.to_i }
      if requirement && changed_requirement?(v, requirement)
        @changed_reqs << requirement[:id]
      end
    end
    send_overrides_to_settings
  end

  def send_overrides_to_settings
    @changed_reqs = @changed_reqs.blank? ? false : @changed_reqs.join(",")
    SettingsService.update_settings(
      object: 'course',
      id: @context.id,
      setting: 'threshold_overrides',
      value: @changed_reqs
    )
  end

  def changed_requirement?(param_requirement, current_requirement)
    param_requirement["type"] != current_requirement[:type] ||
    (current_requirement[:min_score] && param_requirement[:min_score].to_f != current_requirement[:min_score])
  end
end
