module Workshop7

  class HackerNews
    def call(env)
      [200, {"Content-Type" => "text/html"}, "Hacker News"]
    end
  end
end
