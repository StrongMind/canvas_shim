class DiscussionEntry < ActiveRecord::Base
  belongs_to :discussion_topic

  def unread?(teacher)
    self[:unread] == true
  end

  def change_read_state(new_state, current_user = nil, opts = {})
    'implemented in LMS'
  end
end
require File.expand_path('../../app/models/discussion_entry', CanvasShim::Engine.called_from)
