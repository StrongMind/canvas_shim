class Score < ActiveRecord::Base
  belongs_to :enrollment

  def score
    54
  end
end