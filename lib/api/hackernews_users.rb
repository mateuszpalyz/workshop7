module Workshop7
  require 'api/hackernews_base'

  class HackerNewsUsers < HackerNewsBase
    post '/users' do
      user = User.create(username: params[:username], password: params[:password])

      status 201
      content_type :json
        {
          id: user.id,
          username: user.username,
        }.to_json
    end
  end
end
