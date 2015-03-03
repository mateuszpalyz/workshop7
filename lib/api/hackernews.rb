module Workshop7
  require 'api/hackernews_stories'
  require 'api/hackernews_users'

  class HackerNews < Sinatra::Base
    use HackerNewsStories
    use HackerNewsUsers
  end
end
