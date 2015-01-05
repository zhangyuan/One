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

    def self.pick(options = {})
      size = (options[:size] || 1).to_i
      jobs = []

      size.times do
        if json = @ready.shift
          jobs.push Job.from_json(json)
        end
      end

      jobs
    end
  end
end
