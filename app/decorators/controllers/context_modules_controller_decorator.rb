ContextModulesController.class_eval do
  def strongmind_add_item
    instructure_add_item
    return unless gradeable_tag_type? && threshold_set?
    add_threshold_to_module
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  def strongmind_update
    @module = @context.context_modules.not_deleted.find(params[:id])
    add_overrides if authorized_action(@module, @current_user, :update)
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  private
  def gradeable_tag_type?
    %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@tag.content_type)
  end

  def add_threshold_to_module
    @module.completion_requirements << {:id => @tag.id, :type => "min_score", :min_score => score_threshold}
    @module.update_column(:completion_requirements, @module.completion_requirements)
  end

  def add_overrides
    select_changed_requirements.each do |requirement|
      requirement[:overridden] = true
    end
  end

  def select_changed_requirements
    context_module_params[:completion_requirements].to_h.select do |k, v|
      requirement = @module.completion_requirements.find {|req| req[:id] == k.to_i }
      if requirement
        if v["type"] != requirement[:type]
          true
        elsif requirement[:min_score]
          v[:min_score].to_f != requirement[:min_score]
        end
      end
    end
  end
end
