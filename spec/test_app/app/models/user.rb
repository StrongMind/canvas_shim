class User < ActiveRecord::Base
  belongs_to :course
  has_one :pseudonym
  include CanvasShim::User
end
