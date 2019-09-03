class SubmissionComment < ActiveRecord::Base
  belongs_to :submission
  belongs_to :author, :class_name => 'User'
end
