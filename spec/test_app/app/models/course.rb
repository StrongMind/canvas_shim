class Course < ActiveRecord::Base
  has_many :students
  has_many :context_modules
end
