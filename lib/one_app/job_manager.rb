module OneApp
  class JobManager
    def initialize
      @ready_list = Redis::List.new('job:ready')
      @pending_set = Redis::SortedSet.new("job:pending")
    end

    def ready(limit = 1, offset = 0)
      @ready_list.range(offset, offset + limit).map do |item|
        Job.from_json(item)
      end
    end

    def create(job)
      @ready_list << job.to_json 
    end

    def pick(options = {})
      size = (options[:size] || 1).to_i
      jobs = []

      timeout_at = Time.now.to_i + 10 * 60

      size.times do
        if json = @ready_list.shift
          job = Job.from_json(json)
          job.timeout_at = timeout_at
          jobs << job
          @pending_set[job.to_json] = timeout_at
        end
      end

      jobs
    end

    def delete(hash)
      @pending_set.delete(MultiJson.encode(hash))
    end

    def pending
      @pending_set.rangebyscore('-inf', '+inf').map do |json|
        Job.from_json(json)
      end
    end

    def retry_expired(options = {})
      limit = options[:limit] || 10
      score = Time.now.to_i
      @pending_set.rangebyscore('-inf', score, limit: limit, offset: 0).each do |j|
        job = Job.from_json(j)
        job.retry_times += 1
        create(job)
      end
    end
  end
end
