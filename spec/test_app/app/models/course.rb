class Course < ActiveRecord::Base
  has_many :users
  has_many :context_modules
  has_many :assignment_groups
  has_many :assignments

  def teachers
    users
  end
end
