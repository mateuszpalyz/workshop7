module Workshop7
  require 'api/hackernews_base'

  class HackerNewsUsers < HackerNewsBase
    post '/users' do
      user = User.new(JSON.parse request.body.read)

      if user.save
        status 201
        content_type format
        convert_to_correct_format(user, except: [:password])
      else
        status 422
        content_type format
        convert_to_correct_format(user.errors)
      end
    end
  end
end
