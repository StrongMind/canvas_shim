class Progress < ActiveRecord::Base
  belongs_to :course

  def update_completion!(value)
    update_attribute(:completion, value)
  end

  def calculate_completion!(current_value, total)
    update_completion!(100.0 * current_value / total)
  end
end