module Workshop7
  require 'sinatra'
  require 'json'
  require 'yaml'
  require 'active_record'

  class HackerNews < Sinatra::Base
    configure do
      db_options = YAML.load_file('config/database.yml')[environment.to_s]
      ActiveRecord::Base.establish_connection(db_options)
    end

    get '/' do
      'Sinatra !!!'
    end

    get '/stories' do
      content_type :json
      Story.all.to_json
    end

    get '/stories/:id' do
      Story.find(params[:id]).to_json
    end
  end
end
