class SubmissionComment < ActiveRecord::Base
  belongs_to :submission
  belongs_to :author, :class_name => 'User'
  belongs_to :context, polymorphic: true
end
