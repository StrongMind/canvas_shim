module Api::V1::ContextModule
  def module_json(context_module, user, session, progression = nil, includes = [])
    {"id" => context_module.id}
  end
end