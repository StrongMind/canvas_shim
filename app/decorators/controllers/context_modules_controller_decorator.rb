ContextModulesController.class_eval do
  def strongmind_add_item
    instructure_add_item
    return unless gradeable_tag_type? && threshold_set?
    add_threshold_to_module
  end

  alias_method :instructure_add_item, :add_item
  alias_method :add_item, :strongmind_add_item

  def update
    @module = @context.context_modules.not_deleted.find(params[:id])
    if authorized_action(@module, @current_user, :update)
      if params[:publish]
        @module.publish
        @module.publish_items!
      elsif params[:unpublish]
        @module.unpublish
      end
      if add_overrides_and_update_module
        json = @module.as_json(:include => :content_tags, :methods => :workflow_state, :permissions => {:user => @current_user, :session => session})
        json['context_module']['relock_warning'] = true if @module.relock_warning?
        render :json => json
      else
        render :json => @module.errors, :status => :bad_request
      end
    end
  end

  private
  def gradeable_tag_type?
    %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@tag.content_type)
  end

  def add_threshold_to_module
    @module.completion_requirements << {:id => @tag.id, :type => "min_score", :min_score => score_threshold}
    @module.update_column(:completion_requirements, @module.completion_requirements)
  end

  def add_overrides_and_update_module
    cmps = context_module_params.to_h.dup
    cmps[:completion_requirements].to_h.each do |k, v|
      requirement = @module.completion_requirements.find {|req| req[:id] == k.to_i }
      cmps[:completion_requirements][k]["overridden"] = true if requirement && changed_requirement?(v, requirement)
    end
    @module.update_attributes(cmps)
  end

  def changed_requirement?(param_requirement, current_requirement)
    param_requirement["type"] != current_requirement[:type] ||
    (current_requirement[:min_score] && param_requirement[:min_score].to_f != current_requirement[:min_score])
  end
end
