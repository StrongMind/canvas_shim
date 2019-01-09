class DiscussionTopic < ActiveRecord::Base
  belongs_to :context, polymorphic: true
  has_many :discussion_entries
  belongs_to :assignment

  def course
    context
  end
end
