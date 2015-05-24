module OneApp
  class App < Sinatra::Base
    attr_accessor :manager

    before do
      content_type 'application/json'
      self.manager = JobManager.new
    end

    get '/' do
      "hello"
    end

    get '/jobs/ready' do
      jobs = manager.ready

      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name
          json.params job.params
          json.created_at job.created_at
          json.retry_times job.retry_times
        end
      end

      builder.target!
    end

    post '/jobs' do
      manager.create  Job.new(name: parsed_body['name'], params: parsed_body['params'], created_at: Time.now.to_i)
      status 201
    end

    get '/jobs/pick' do
      options = {}
      if params['size'].to_i > 0
        options[:size] = params['size']
      end
      jobs = manager.pick(options)

      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name
          json.params job.params
          json.expires_at job.expires_at
          json.created_at job.created_at
          json.retry_times job.retry_times
        end
      end
      builder.target!
    end

    get '/jobs/pending' do
      jobs = manager.pending
      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name 
          json.params job.params
          json.expires_at job.expires_at
          json.created_at job.created_at
          json.retry_times job.retry_times
        end
      end

      builder.target!
    end

    post '/jobs/finish' do
      parsed_body.each do |job|
        manager.delete(job)
      end

      builder = Jbuilder.new do |json|
        json.status 0
      end

      builder.target!
    end

    protected
    
    def parsed_body
      @parsed_body ||= MultiJson.decode(request.body) 
    end
  end
end
