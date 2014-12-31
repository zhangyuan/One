module OneApp
  class App < Sinatra::Base
    before do
      content_type 'application/json'
    end

    get '/' do
      "hello"
    end

    get '/jobs' do
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
      job = MultiJson.decode(request.body.read)
      JobManager.create(job)

      status 201
    end
  end
end
