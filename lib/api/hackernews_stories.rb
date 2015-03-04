module Workshop7
  require 'api/hackernews_base'

  class HackerNewsStories < HackerNewsBase
    get '/stories' do
      content_type format
      convert_to_correct_format(Story.all)
    end

    get '/stories/:id' do
      content_type format
      convert_to_correct_format(Story.find(params[:id]))
    end

    post '/stories' do
      protected!

      story = Story.create((JSON.parse request.body.read).merge user_id: @user.id)

      status 201
      content_type format
      data = {
          id: story.id,
          title: story.title,
          url: story.url,
          user_id: story.user_id,
        }
      convert_to_correct_format(data)
    end

    patch '/stories/:id' do
      protected!

      story = Story.find(params[:id])
      updateable(story)

      story.update(JSON.parse request.body.read)

      status 200
      content_type format
      data = {
          id: story.id,
          title: story.title,
          url: story.url,
        }
      convert_to_correct_format(data)
    end

    put '/stories/:id/votes' do
      protected!

      vote = Vote.find_or_initialize_by(user_id: @user.id, story_id: params[:id])
      vote.point = (JSON.parse request.body.read)['point']
      vote.save

      status 201
      content_type format
      data = {
          points: Story.find(params[:id]).points
        }
      convert_to_correct_format(data)
    end

    delete '/stories/:id/votes' do
      protected!

      vote = Vote.find_by!(user_id: @user.id, story_id: params[:id])
      vote.destroy

      status 204
    end
  end
end
