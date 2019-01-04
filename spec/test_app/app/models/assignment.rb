class Assignment < ActiveRecord::Base
  has_many :submissions
  has_one :discussion_topic
  belongs_to :context, class_name: 'Course'
  belongs_to :course
  belongs_to :assignment_group

  def due_date
    due_at
  end
end
