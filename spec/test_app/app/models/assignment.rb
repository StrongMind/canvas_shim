class Assignment < ActiveRecord::Base
  has_many :submissions
  belongs_to :context, class_name: 'Course'
  def due_date
    due_at
  end
end
