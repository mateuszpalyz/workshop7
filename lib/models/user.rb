require 'active_record'

class User < ActiveRecord::Base
  has_many :stories
  has_many :votes

  validates_presence_of :username, :password
end
