module Workshop7
  require 'sinatra'
  require 'json'
  require 'yaml'
  require 'active_record'
  require 'models/story'
  require 'models/user'

  class HackerNewsBase < Sinatra::Base
    configure do
      db_options = YAML.load_file('config/database.yml')[environment.to_s]
      ActiveRecord::Base.establish_connection(db_options)
    end
  end
end
