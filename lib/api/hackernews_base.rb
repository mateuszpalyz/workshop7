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

    set :show_exceptions, :after_handler

    configure do
      db_options = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : YAML.load_file('config/database.yml')[environment.to_s]
      ActiveRecord::Base.establish_connection(db_options)
    end

    error JSON::ParserError do
      status 422
    end

    error ActiveRecord::RecordInvalid do |invalid|
      status 422
      content_type format
      convert_to_correct_format(invalid.record.errors)
    end

    error ActiveRecord::RecordNotFound do
      status 422
    end
  end
end
