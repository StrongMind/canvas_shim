class ContentTag < ActiveRecord::Base
  belongs_to :content, polymorphic: true
  belongs_to :context, polymorphic: true
  belongs_to :context_module
  belongs_to :assignment

  def course
    return context if context_type == 'Course'
  end

  def content
    assignment
  end
end
