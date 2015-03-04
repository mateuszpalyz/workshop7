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

    patch '/stories/:id' do
      protected!

      story = Story.find(params[:id])
      updateable(story)

      story.update(JSON.parse request.body.read)

      status 200
      content_type :json
        {
          id: story.id,
          title: story.title,
          url: story.url,
        }.to_json
    end

    put '/stories/:id/votes' do
      protected!

      vote = Vote.find_or_initialize_by(user_id: @user.id, story_id: params[:id])
      vote.point = params[:point]
      vote.save

      status 201
      content_type :json
        {
          points: Story.find(params[:id]).points
        }.to_json
    end

    delete '/stories/:id/votes' do
      protected!

      vote = Vote.find_by!(user_id: @user.id, story_id: params[:id])
      vote.destroy

      status 204
    end
  end
end
