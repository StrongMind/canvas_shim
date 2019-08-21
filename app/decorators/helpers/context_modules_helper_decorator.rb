ContextModulesHelper.class_eval do
  def module_item_excused?(module_item)
    module_item && module_item.try_rescue(:assignment).try_rescue(:is_excused?, @current_user)
  end
end
