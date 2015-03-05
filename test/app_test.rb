require 'minitest/autorun'
require 'rack/test'
require 'rack/lint'
require 'api/hackernews'
require 'database_cleaner'
require 'xmlsimple'

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
    User.create(username: "johnny", password: "bravo")
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

  def test_getting_a_single_story_as_xml
    header 'Accept', 'application/xml'
    get '/stories/1'
    response = XmlSimple.xml_in last_response.body

    assert last_response.ok?
    assert 'application/xml', last_response.content_type
    assert_equal 'Lorem ipsum', response['title'].first
  end

  def test_redirect_to_a_given_story
    get '/stories/1/url'

    assert_equal 303, last_response.status
  end

  def test_submitting_a_new_story_with_correct_credentails
    authorize 'johnny', 'bravo'
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com' }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 'Funny title', response['title']
    assert_equal 1, response['user_id']
  end

  def test_submitting_a_new_story_with_wrong_credentails
    authorize 'bad', 'boy'
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com' }.to_json

    assert_equal 401, last_response.status
    assert_equal 'Basic realm="Restricted Area"', last_response.headers['WWW-Authenticate']
  end

  def test_submitting_a_new_story_without_credentails
    post '/stories', { title: 'Funny title', url: 'http://www.funny.com' }.to_json

    assert_equal 401, last_response.status
    assert_equal 'Basic realm="Restricted Area"', last_response.headers['WWW-Authenticate']
  end

  def test_updating_a_story_that_belongs_to_the_user
    authorize 'johnny', 'bravo'

    patch '/stories/1', { title: 'Updated shiny title'}.to_json
    response = JSON.parse last_response.body

    assert last_response.ok?
    assert_equal 'Updated shiny title', response['title']
  end

  def test_updating_a_story_that_does_not_belong_to_the_user
    User.create(username: "bad", password: "boy")
    authorize 'bad', 'boy'

    patch '/stories/1', { title: 'Updated shiny title'}.to_json

    assert_equal 403, last_response.status
  end

  def test_upvoting_a_story
    authorize 'johnny', 'bravo'

    put '/stories/1/votes', { point: 1 }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 1, response['points']
  end

  def test_downvoting_a_story
    authorize 'johnny', 'bravo'

    put '/stories/1/votes', { point: -1 }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal -1, response['points']
  end

  def test_undoing_a_vote
    Vote.create(user_id: 1, story_id: 1, point: 1)
    authorize 'johnny', 'bravo'

    delete '/stories/1/votes'

    assert_equal 204, last_response.status
  end

  def test_creating_a_user
    post '/users', { username: 'John Doe', password: 'secret' }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 'John Doe', response['username']
  end

  def teardown
    DatabaseCleaner.clean
  end
end
