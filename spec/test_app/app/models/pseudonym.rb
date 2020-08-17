class Pseudonym < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  scope :active, -> { Pseudonym.all }

  def send_later_if_production(*args)
    true
  end
end
