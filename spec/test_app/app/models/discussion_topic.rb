class DiscussionTopic < ActiveRecord::Base
  belongs_to :context, polymorphic: true

  def course
    context
  end
end
