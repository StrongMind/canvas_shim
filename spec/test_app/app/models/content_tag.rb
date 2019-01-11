class ContentTag < ActiveRecord::Base
  belongs_to :content, polymorphic: true
  belongs_to :context_module
  belongs_to :assignment
end
