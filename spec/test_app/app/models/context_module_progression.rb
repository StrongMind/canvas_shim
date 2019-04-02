class ContextModuleProgression < ActiveRecord::Base
  belongs_to :context_module
  belongs_to :user

  def prerequisites_satisfied?
    false
  end
end
