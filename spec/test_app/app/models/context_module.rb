class ContextModule < ActiveRecord::Base
  has_many :content_tags
  belongs_to :course
end
