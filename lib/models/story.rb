require 'active_record'

class Story < ActiveRecord::Base
  belongs_to :user
  has_many :votes

  def points
    votes.sum(:point)
  end
end
