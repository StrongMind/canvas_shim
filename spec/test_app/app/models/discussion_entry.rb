class DiscussionEntry < ActiveRecord::Base
  belongs_to :discussion_topic

  def unread?(teacher)
    self[:unread] == true
  end

  def change_read_state
    'implemented in LMS'
  end
  include CanvasShim::DiscussionEntry
end
