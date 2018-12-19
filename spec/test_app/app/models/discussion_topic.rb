class DiscussionTopic < ActiveRecord::Base
  belongs_to :context, polymorphic: true
  has_many :discussion_entries

  def course
    context
  end
end
