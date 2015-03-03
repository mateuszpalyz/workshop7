module Workshop7
  require 'api/hackernews_base'
  require 'api/helpers'

  class HackerNewsStories < HackerNewsBase
    include Workshop7::Helpers

    get '/stories' do
      content_type :json
      Story.all.to_json
    end

    get '/stories/:id' do
      Story.find(params[:id]).to_json
    end

    post '/stories' do
      protected!

      story = Story.create(title: params[:title], url: params[:url])

      status 201
      content_type :json
        {
          id: story.id,
          title: story.title,
          url: story.url,
        }.to_json
    end
  end
end
