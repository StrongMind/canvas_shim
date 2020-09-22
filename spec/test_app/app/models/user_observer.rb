class UserObserver < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_observees
  belongs_to :observer, :class_name => 'User', inverse_of: :user_observers

  scope :active, -> { where("workflow_state IS NULL OR workflow_state <> 'deleted'") }
  
  def self.create_or_restore(attributes)
    if (user_observer = where(attributes).take)
      if user_observer.workflow_state == 'deleted'
        user_observer.workflow_state = 'active'
        user_observer.sis_batch_id = nil
        user_observer.save!
      end
      user_observer.create_linked_enrollments
    else
      user_observer = create!(attributes)
    end
    user_observer.user.touch
    user_observer
  end

  def destroy
    self.workflow_state = 'deleted'
    self.save!
  end
end
