module Workshop7
  require 'sinatra'
  require 'json'
  require 'yaml'
  require 'active_record'
  require 'models/story'
  require 'models/user'
  require 'models/vote'
  require 'api/helpers'

  class HackerNewsBase < Sinatra::Base
    include Workshop7::Helpers

    configure do
      db_options = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : YAML.load_file('config/database.yml')[environment.to_s]
      ActiveRecord::Base.establish_connection(db_options)
    end
  end
end
