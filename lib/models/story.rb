require 'active_record'

class Story < ActiveRecord::Base
  belongs_to :user
end
