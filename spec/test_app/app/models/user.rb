class User < ActiveRecord::Base
  belongs_to :course
  has_one :pseudonym
end
require File.expand_path('../../app/models/user', CanvasShim::Engine.called_from)