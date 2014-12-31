module OneApp
  class JobManager
    @ready = Redis::List.new('job:ready')

    def self.ready(limit = 1, offset = 0)
      @ready.range(offset, offset + limit).map do |item|
        Job.from_json(item)
      end
    end

    def self.create(options)
      @ready << Job.new(options).to_json
    end
  end
end
