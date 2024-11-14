class Assignment < ActiveRecord::Base
  has_many :submissions
  has_many :assignment_overrides
  has_many :all_submissions, class_name: "Submission"
  has_one :discussion_topic
  belongs_to :context, class_name: 'Course'
  belongs_to :course
  belongs_to :assignment_group

  has_many :context_module_tags, -> { where("content_tags.tag_type='context_module' AND content_tags.workflow_state<>'deleted'").preload(context_module: :content_tags) }, as: :content, inverse_of: :content, class_name: 'ContentTag'

  def due_date
    due_at
  end

  def name
    'Assignment Yo Yo'
  end
end
