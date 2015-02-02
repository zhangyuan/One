module OneApp
  class JobManager
    @ready = Redis::List.new('job:ready')
    @pending = Redis::SortedSet.new("job:pending")

    def self.ready(limit = 1, offset = 0)
      @ready.range(offset, offset + limit).map do |item|
        Job.from_json(item)
      end
    end

    def self.create(name, params)
      @ready << Job.new(name: name, params: params).to_json
    end

    def self.pick(options = {})
      size = (options[:size] || 1).to_i
      jobs = []

      expires_at = Time.now.to_i + 6000

      size.times do
        if json = @ready.shift
          job = Job.from_json(json)
          job.expires_at = expires_at
          jobs << job
          @pending[job.to_json] = expires_at
        end
      end

      jobs
    end

    def self.delete(hash)
      @pending.delete(MultiJson.encode(hash))
    end

    def self.pending
      @pending.rangebyscore('-inf', '+inf').map do |json|
        Job.from_json(json)
      end
    end
  end
end
