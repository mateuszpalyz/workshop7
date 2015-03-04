module Workshop7

  module Helpers
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, 'Not authorized\n'
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and correct_credentials?(@auth.credentials)
    end

    def correct_credentials?(credentials)
      username, password = credentials
      @user = User.find_by(username: username)
      @user.password == password if @user
    end

    def updateable(story)
      halt 403, 'Not authorized\n' unless story.user_id == @user.id
    end
  end
end
