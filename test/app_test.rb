require 'minitest/autorun'
require 'rack/test'
require 'rack/lint'
require 'workshop7/hackernews'

class AppTest < Minitest::Test
  include Rack::Test::Methods
  include Workshop7

  def app
    Rack::Lint.new(HackerNews.new)
  end

  def test_response
    get '/'

    assert last_response.ok?
  end

  def test_getting_list_of_all_submitted_stories
    skip
    get '/stories'

    assert last_response.ok?
  end

  def test_getting_a_single_story
    skip
    get '/stories/1'

    assert last_response.ok?
  end

  def test_submitting_a_new_story
    skip
    post '/stories', {}

    assert_equal 201, last_response.status
  end

  def test_updating_a_story
    skip
    patch '/stories/1', {}

    assert last_response.ok?
  end

  def test_upvoting_a_story
    skip
    put '/stories/1/votes', {}

    assert_equal 201, last_response.status
  end

  def test_downvoting_a_story
    skip
    put '/stories/1/votes', {}

    assert_equal 201, last_response.status
  end

  def test_undoing_a_vote
    skip
    delete '/stories/1/votes'

    assert_equal 204, last_response.status
  end

  def test_creating_a_user
    skip
    post '/users', {}

    assert_equal 201, last_response.status
  end
end
