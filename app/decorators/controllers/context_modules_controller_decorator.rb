ContextModulesController.class_eval do
  def strongmind_update
    @module = @context.context_modules.not_deleted.find(params[:id])
    add_threshold_overrides if can_add_threshold_overrides?
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

  def can_add_threshold_overrides?
    !disable_module_editing_on? && && context_module_params[:completion_requirements] &&
    authorized_action(@module, @current_user, :update)
  end

  def add_threshold_overrides
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
    @all_reqs = conjoin_threshold_overrides(@changed_reqs)
    @all_reqs = @all_reqs.blank? ? false : @all_reqs.join(",")
    SettingsService.update_settings(
      object: 'course',
      id: @context.id,
      setting: 'threshold_overrides',
      value: @all_reqs
    )
  end

  def get_threshold_overrides
    @threshold_overrides ||= SettingsService.get_settings(object: :course, id: @context.try(:id))['threshold_overrides']
  end

  def conjoin_threshold_overrides(new_overrides)
    if get_threshold_overrides
      current_overrides = get_threshold_overrides.split(",")
      return current_overrides unless new_overrides.any?
      current_overrides.concat(new_overrides).uniq
    elsif new_overrides.any?
      new_overrides
    else
      []
    end
  end

  def changed_requirement?(param_requirement, current_requirement)
    param_requirement["type"] != current_requirement[:type] ||
    (current_requirement[:min_score] && param_requirement[:min_score].to_f != current_requirement[:min_score])
  end
end
