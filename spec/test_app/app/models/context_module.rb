class ContextModule < ActiveRecord::Base
  has_many :content_tags
  belongs_to :course
  belongs_to :context, polymorphic: true
end
