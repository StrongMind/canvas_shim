class ContentMigration < ActiveRecord::Base
  belongs_to :context, polymorphic: true
end
