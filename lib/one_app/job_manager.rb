module OneApp
  class JobManager
    @ready = Redis::List.new('job:ready')

    def self.ready(limit = 1, offset = 0)
      @ready.range(offset, offset + limit).map do |item|
        Job.from_json(item)
      end
    end

    def self.create(name, params)
      @ready << Job.new(name: name, params: params).to_json
    end

    def self.pick
      if job = @ready.shift
        [Job.from_json(job)]
      else
        []
      end
    end
  end
end
