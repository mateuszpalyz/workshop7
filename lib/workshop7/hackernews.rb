module Workshop7
  require 'sinatra'
  require 'json'

  class HackerNews < Sinatra::Base
    get '/' do
      'Sinatra !!!'
    end

    get '/stories' do
      content_type :json
      [
        {
          id: 1,
          title: 'Lorem ipsum',
          url: 'http://www.lipsum.com/',
        },
        {
          id: 2,
          title: 'Ipsum Lorem',
          url: 'http://www.ipsum.com',
        },
      ].to_json
    end

    get '/stories/:id' do
      content_type :json
      {
        id: 1,
        title: 'Lorem ipsum',
        url: 'http://www.lipsum.com/',
      }.to_json
    end
  end
end
