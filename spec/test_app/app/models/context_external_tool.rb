class ContextExternalTool < ActiveRecord::Base
  belongs_to :course
  belongs_to :context, polymorphic: true
end