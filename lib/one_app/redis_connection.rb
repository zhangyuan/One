module OneApp
  class RedisConnection
    def self.current
      @redis
    end

    def self.connect!
      @redis = Redis.new
    end
  end
end
