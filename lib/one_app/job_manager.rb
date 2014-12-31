module OneApp
  class JobManager
    @ready = Redis::List.new('job:ready')

    def self.ready(limit = 1, offset = 0)
      @ready.range(offset, offset + limit).map do |item|
        MultiJson.decode(item)
      end
    end

    def self.create(options)
      @ready << MultiJson.encode(options)
    end
  end
end
