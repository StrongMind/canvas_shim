class Pseudonym < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  def send_later_if_production(*args)
    true
  end
end
