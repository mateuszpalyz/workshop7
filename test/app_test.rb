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

  def test_quality_parameter_in_accept_header
    header 'Accept', 'application/json;q=0.5,application/xml;q=0.8'
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

  def test_submitting_incorrect_story_with_correct_credentials
    authorize 'johnny', 'bravo'
    post '/stories', { title: 'without url' }.to_json
    response = JSON.parse last_response.body

    assert_equal 422, last_response.status
    assert_equal "can't be blank", response['url'].first
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

  def test_updating_a_story_that_belongs_to_the_user_but_is_incorrect
    authorize 'johnny', 'bravo'

    patch '/stories/1', { title: nil}.to_json
    response = JSON.parse last_response.body

    assert_equal 422, last_response.status
    assert_equal "can't be blank", response['title'].first
  end

  def test_updating_a_story_that_does_not_belong_to_the_user
    User.create(username: "bad", password: "boy")
    authorize 'bad', 'boy'

    patch '/stories/1', { title: 'Updated shiny title'}.to_json

    assert_equal 403, last_response.status
  end

  def test_upvoting_a_story
    authorize 'johnny', 'bravo'

    put '/stories/1/vote', { point: 1 }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 1, response['points']
  end

  def test_upvoting_a_story_few_times
    authorize 'johnny', 'bravo'

    3.times { put '/stories/1/vote', { point: 1 }.to_json }
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 1, response['points']
  end

  def test_upvoting_a_story_when_number_of_points_is_abused
    authorize 'johnny', 'bravo'

    3.times { put '/stories/1/vote', { point: 6 }.to_json }
    response = JSON.parse last_response.body

    assert_equal 422, last_response.status
    assert_equal "is not included in the list", response['point'].first
  end

  def test_downvoting_a_story
    authorize 'johnny', 'bravo'

    put '/stories/1/vote', { point: -1 }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal -1, response['points']
  end

  def test_downvoting_a_story_few_times
    authorize 'johnny', 'bravo'

    3.times { put '/stories/1/vote', { point: -1 }.to_json }
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal -1, response['points']
  end

  def test_downvoting_a_story_when_number_of_points_is_abused
    authorize 'johnny', 'bravo'

    3.times { put '/stories/1/vote', { point: -6 }.to_json }
    response = JSON.parse last_response.body

    assert_equal 422, last_response.status
    assert_equal "is not included in the list", response['point'].first
  end

  def test_undoing_a_vote
    Vote.create(user_id: 1, story_id: 1, point: 1)
    authorize 'johnny', 'bravo'

    delete '/stories/1/vote'

    assert_equal 204, last_response.status
  end

  def test_undoing_a_vote_that_does_not_exsist
    authorize 'johnny', 'bravo'

    delete '/stories/1/vote'

    assert_equal 422, last_response.status
  end

  def test_creating_a_user
    post '/users', { username: 'John Doe', password: 'secret' }.to_json
    response = JSON.parse last_response.body

    assert_equal 201, last_response.status
    assert_equal 'John Doe', response['username']
  end

  def test_submitting_incorrect_user
    post '/users', { password: 'secret' }.to_json
    response = JSON.parse last_response.body

    assert_equal 422, last_response.status
    assert_equal "can't be blank", response['username'].first
  end

  def teardown
    DatabaseCleaner.clean
  end
end
