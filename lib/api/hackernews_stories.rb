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

      story = Story.new((JSON.parse request.body.read).merge user_id: @user.id)

      if story.save
        status 201
        content_type format
        convert_to_correct_format(story)
      else
        status 422
        content_type format
        convert_to_correct_format(story.errors)
      end
    end

    patch '/stories/:id' do
      protected!

      story = Story.find(params[:id])
      updateable(story)

      if story.update(JSON.parse request.body.read)
        status 200
        content_type format
        convert_to_correct_format(story)
      else
        status 422
        content_type format
        convert_to_correct_format(story.errors)
      end
    end

    put '/stories/:id/vote' do
      protected!

      point = (JSON.parse request.body.read)['point']
      vote = Vote.find_or_initialize_by(user_id: @user.id, story_id: params[:id], point: point)

      if vote.save
        status 201
        content_type format
        data = {
            points: Story.find(params[:id]).points
          }
        convert_to_correct_format(data)
      else
        status 422
        content_type format
        convert_to_correct_format(vote.errors)
      end
    end

    delete '/stories/:id/vote' do
      protected!

      vote = Vote.find_by!(user_id: @user.id, story_id: params[:id])
      vote.destroy

      status 204
    end

    get '/stories/:id/url' do
      redirect Story.find(params[:id]).url, 303
    end
  end
end
