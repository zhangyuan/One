require File.expand_path("../spec_helper", __FILE__)

describe "app" do
  describe 'GET /' do
    it 'should be ok' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'GET /jobs' do
    it 'should be ok' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'should return jobs' do
      get '/jobs'
      jobs = MultiJson.decode(last_response.body)
      expect(jobs).to be_instance_of(Array)
    end
  end

  describe 'POST /jobs' do
    it 'should create job' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}

      get '/jobs'

      jobs = MultiJson.decode(last_response.body)

      expect(jobs).to be_instance_of(Array)
      expect(jobs.length).to eq(1)
      expect(jobs[0]['name']).to eq('jobs/name')
      expect(jobs[0]['params']).to eq({'id' => 1})
    end
  end
end
