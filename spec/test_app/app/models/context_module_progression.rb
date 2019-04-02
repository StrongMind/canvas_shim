class ContextModuleProgression < ActiveRecord::Base
  def prerequisites_satisfied?
    true
  end
end
