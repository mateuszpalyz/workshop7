module Workshop7

  module Helpers
    def protected!(story=nil)
      return if authorized? && updateable?(story)
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

    def updateable?(story)
      if story && story.user_id != @user.id
        halt 403, 'Not authorized\n'
      else
        true
      end
    end

    def to_json_or_xml
      ('to_' + format).to_sym
    end

    def convert_to_correct_format(data, options={})
      data.send(to_json_or_xml, options)
    end

    def format
      request.accept.first.to_s == 'application/xml' ? 'xml' : 'json'
    end
  end
end
