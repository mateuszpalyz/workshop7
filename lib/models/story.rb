require 'active_record'

class Story < ActiveRecord::Base
  belongs_to :user
  has_many :votes

  validates_presence_of :user_id, :title, :url

  def points
    votes.sum(:point)
  end
end
