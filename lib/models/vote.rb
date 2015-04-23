require 'active_record'

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

  validates :point, inclusion: { in: [1, -1] }
end
