require 'minitest/autorun'
require 'rack/test'
require 'rack/lint'
require 'api/hackernews'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class AppTest < Minitest::Test
  include Rack::Test::Methods
  include Workshop7

  def app
    Rack::Lint.new(HackerNews.new)
  end

  def setup
    DatabaseCleaner.start
    Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com/', user_id: 1)
  end

  def test_getting_list_of_all_submitted_stories
    Story.create!(title: 'Ipsum lorem', url: 'http://www.ipsum.com/', user_id: 1)

    get '/stories'
    response = JSON.parse last_response.body

    assert last_response.ok?
    assert 'application/json', last_response.content_type
    assert_equal 'Lorem ipsum', response.first['title']
    assert_equal 'Ipsum lorem', response.last['title']
  end

  def test_getting_a_single_story
    get '/stories/1'
    response = JSON.parse last_response.body

    assert last_response.ok?
    assert 'application/json', last_response.content_type
    assert_equal 'Lorem ipsum', response['title']
  end

  def test_submitting_a_new_story_with_correct_credentails
    authorize 'admin', 'admin'
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com', user_id: 1 }
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 'Funny title', response['title']
  end

  def test_submitting_a_new_story_with_wrong_credentails
    authorize 'bad', 'boy'
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com', user_id: 1 }

    assert_equal 401, last_response.status
    assert_equal 'Basic realm="Restricted Area"', last_response.headers['WWW-Authenticate']
  end

  def test_submitting_a_new_story_without_credentails
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com', user_id: 1 }

    assert_equal 401, last_response.status
    assert_equal 'Basic realm="Restricted Area"', last_response.headers['WWW-Authenticate']
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
    post '/users', { username: 'John Doe', password: 'secret' }
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 'John Doe', response['username']
  end

  def teardown
    DatabaseCleaner.clean
  end
end
