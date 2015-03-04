module Workshop7
  require 'api/hackernews_base'

  class HackerNewsUsers < HackerNewsBase
    post '/users' do
      user = User.create(JSON.parse request.body.read)

      status 201
      content_type format
      data = {
          id: user.id,
          username: user.username,
        }
      convert_to_correct_format(data)
    end
  end
end
