class Course < ActiveRecord::Base
  has_many :enrollments
  has_many :teacher_enrollments
  has_many :users, through: :enrollments
  has_many :context_modules
  has_many :context_module_progressions, through: :context_modules
  has_many :assignment_groups
  has_many :assignments
  has_many :submissions, through: :assignments
  has_many :context_external_tools
  has_many :progresses

  def teachers
    users
  end

  def module_based?
    true
  end

  def user_is_student?(one, options={})
    true
  end

  def self.default_tabs; end
end
