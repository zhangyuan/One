module OneApp
  class App < Sinatra::Base
    before do
      content_type 'application/json'
    end

    get '/' do
      "hello"
    end

    get '/jobs/ready' do
      jobs = JobManager.ready

      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name
          json.params job.params
        end
      end

      builder.target!
    end

    post '/jobs' do
      JobManager.create(parsed_body['name'], parsed_body['params'])
      status 201
    end

    get '/jobs/pick' do
      options = {}
      if params['size'].to_i > 0
        options[:size] = params['size']
      end
      jobs = JobManager.pick(options)

      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name
          json.params job.params
        end
      end

      builder.target!
    end

    get '/jobs/pending' do
      jobs = JobManager.pending
      builder = Jbuilder.new do |json|
        json.array!(jobs) do |job|
          json.name job.name 
          json.params job.params
        end
      end

      builder.target!
    end

    def parsed_body
      @parsed_body ||= MultiJson.decode(request.body) 
    end
  end
end
