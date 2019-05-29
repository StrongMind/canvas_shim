class ContextModuleProgression < ActiveRecord::Base
  belongs_to :context_module
  belongs_to :user
  belongs_to :course

  def prerequisites_satisfied?
    false
  end

  def locked?
    true
  end
end
