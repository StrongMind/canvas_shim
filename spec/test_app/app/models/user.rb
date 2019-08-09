class User < ActiveRecord::Base
  has_many :user_observers, dependent: :destroy, inverse_of: :user
  # has_many :observers, -> { where("user_observers.workflow_state <> 'deleted'") }, :through => :user_observers, :class_name => 'User'
  has_many :user_observees,
           class_name: 'UserObserver',
           foreign_key: :observer_id,
           dependent: :destroy,
           inverse_of: :observer
  has_many :observed_users, :through => :user_observees, :source => :user
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_many :submissions

  has_many :pseudonyms
  has_one :pseudonym, -> { where("pseudonyms.workflow_state<>'deleted'").order(:position) }


  def recent_feedback(opts={})
    self.submissions
  end

  def name
    "Chris Young"
  end
end
