class PageView < ActiveRecord::Base
  def real_user_id
    1
  end

  def updated_at
    Time.now
    
  end
end
