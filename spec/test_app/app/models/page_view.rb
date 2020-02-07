class PageView < ActiveRecord::Base
  def user_id
    1
  end

  def updated_at
    Time.now
    
  end
end
