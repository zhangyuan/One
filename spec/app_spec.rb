require File.expand_path("../spec_helper", __FILE__)

describe "app" do
  describe 'GET /' do
    it 'should be ok' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'GET /jobs/ready' do
    it 'should be ok' do
      get '/jobs/ready'
      expect(last_response).to be_ok
    end

    it 'should return json' do
      get '/jobs/ready'
      expect(last_response.content_type).to eq('application/json')
    end

    it 'should return jobs' do
      get '/jobs/ready'
      jobs = MultiJson.decode(last_response.body)
      expect(jobs).to be_instance_of(Array)
    end
  end

  describe 'POST /jobs' do
    it 'should be created' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}
      expect(last_response).to be_created
    end

    it 'should create job' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}

      get '/jobs/ready'

      jobs = MultiJson.decode(last_response.body)

      expect(jobs).to be_instance_of(Array)
      expect(jobs.length).to eq(1)
      expect(jobs[0]['name']).to eq('jobs/name')
      expect(jobs[0]['params']).to eq({'id' => 1})
    end
  end

  describe 'pick up job' do
    
    describe "when jobs exist" do
      before(:each) do
        post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}

        get '/jobs/pick'
      end

      it 'should be ok' do
        expect(last_response).to be_ok
      end

      it 'should pick up job' do
        jobs = MultiJson.decode(last_response.body)
        expect(jobs).to be_instance_of(Array)
        expect(jobs.length).to eq(1)
        expect(jobs[0]['name']).to eq('jobs/name')
        expect(jobs[0]['params']).to eq({'id' => 1})
      end

      it 'remove the job from ready' do
        get '/jobs/ready'
        jobs = MultiJson.decode(last_response.body)
        expect(jobs.length).to eq(0)
      end
    end

    describe "when no job exists" do
      it "should pick blank list" do
        get '/jobs/pick'
        jobs = MultiJson.decode(last_response.body)
        expect(jobs.length).to eq(0)
      end
    end
  end
end
