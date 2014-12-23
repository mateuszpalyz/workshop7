require 'minitest/autorun'
require 'rack/test'
require 'rack/lint'
require 'workshop7/hackernews'

class AppTest < Minitest::Test
  include Rack::Test::Methods
  include Workshop7

  def app
    HackerNews.new
  end

  def setup
    get '/'
  end

  def test_response
    assert last_response.ok?
  end
end
