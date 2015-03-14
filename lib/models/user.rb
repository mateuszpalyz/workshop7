require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  has_many :stories
  has_many :votes

  validates_presence_of :username, :password

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
