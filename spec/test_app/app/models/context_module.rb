class ContextModule < ActiveRecord::Base
  has_many :content_tags
  belongs_to :course
  belongs_to :context, polymorphic: true
  belongs_to :context_module_progression
  serialize :completion_requirements
end
