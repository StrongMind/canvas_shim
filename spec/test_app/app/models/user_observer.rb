class UserObserver < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_observees
  belongs_to :observer, :class_name => 'User', inverse_of: :user_observers
end
