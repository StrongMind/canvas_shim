class User < ActiveRecord::Base
  has_many :user_observers, dependent: :destroy, inverse_of: :user
  # has_many :observers, -> { where("user_observers.workflow_state <> 'deleted'") }, :through => :user_observers, :class_name => 'User'
  has_many :user_observees,
           class_name: 'UserObserver',
           foreign_key: :observer_id,
           dependent: :destroy,
           inverse_of: :observer
  has_many :observed_users, :through => :user_observees, :source => :user

  belongs_to :course
  has_one :pseudonym
end
require File.expand_path('../../app/models/user', CanvasShim::Engine.called_from)
