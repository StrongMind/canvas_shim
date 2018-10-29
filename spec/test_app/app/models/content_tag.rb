class ContentTag < ActiveRecord::Base
  belongs_to :content, polymorphic: true
end
