require File.expand_path("../spec_helper", __FILE__)

describe "app" do
  after(:each) do
    Timecop.return
  end

  describe 'GET /' do
    it 'should return 403 if app key is valid' do
      get '/'
      expect(last_response).to be_forbidden
    end

    it 'should be ok' do
      get '/', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      expect(last_response).to be_ok
    end
  end

  describe 'GET /jobs/ready' do
    it 'should check app key' do
      get 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}
      expect(last_response).to be_forbidden
    end

    it 'should be ok' do
      get '/jobs/ready', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      expect(last_response).to be_ok
    end

    it 'should return json' do
      get '/jobs/ready', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      expect(last_response.content_type).to eq('application/json')
    end

    it 'should return jobs' do
      get '/jobs/ready', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      jobs = MultiJson.decode(last_response.body)
      expect(jobs).to be_instance_of(Array)
    end
  end

  describe 'POST /jobs' do
    before(:each) do
      Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
    end

    it 'should check app key' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json'}
      expect(last_response).to be_forbidden
    end

    it 'should be created' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      expect(last_response).to be_created
    end

    it 'should create job' do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json',  'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

      get '/jobs/ready', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

      jobs = MultiJson.decode(last_response.body)

      expect(jobs).to be_instance_of(Array)
      expect(jobs.length).to eq(1)
      expect(jobs[0]['name']).to eq('jobs/name')
      expect(jobs[0]['params']).to eq({'id' => 1})
      expect(jobs[0]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
      expect(jobs[0]['retry_times']).to eq(0)
    end
  end

  describe 'GET /jobs/pick' do
    describe "when one job exist" do
      before(:each) do
        Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
        post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

        get '/jobs/pick', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      end

      it 'should check app key' do
        get '/jobs/pick'
        expect(last_response).to be_forbidden
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
        get '/jobs/ready', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
        jobs = MultiJson.decode(last_response.body)
        expect(jobs.length).to eq(0)
      end

      it 'should return timeout_at' do
        jobs = MultiJson.decode(last_response.body)
        expect(jobs[0]['timeout_at']).to be_a(Integer)
      end

      it 'should expire at 10 minutes later' do
        jobs = MultiJson.decode(last_response.body)
        expected_timeout_at = Time.local(2015, 1, 1, 12, 0, 0).to_i + 10 * 60
        expect(jobs[0]['timeout_at']).to eq(expected_timeout_at)
      end

      it 'should appear in pending jobs' do
        get '/jobs/pending', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

        jobs = MultiJson.decode(last_response.body)
        expect(jobs).to be_instance_of(Array)
        expect(jobs.length).to eq(1)
        expect(jobs[0]['name']).to eq('jobs/name')
        expect(jobs[0]['params']).to eq({'id' => 1})
        expect(jobs[0]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
        expected_timeout_at = Time.local(2015, 1, 1, 12, 0, 0).to_i + 10 * 60
        expect(jobs[0]['timeout_at']).to eq(expected_timeout_at.to_i)
      end
    end

    describe "when many jobs exist" do
      it "should pick up multiple jobs" do
        post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
        post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
        post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

        get '/jobs/pick?size=2', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}

        jobs = MultiJson.decode(last_response.body)
        expect(jobs.length).to eq(2)
      end
    end

    describe "when no job exists" do
      it "should pick blank list" do
        get '/jobs/pick', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
        jobs = MultiJson.decode(last_response.body)
        expect(jobs.length).to eq(0)
      end
    end
  end

  describe 'POST /jobs/finish' do
    before(:each) do
      post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      get '/jobs/pick', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      jobs = MultiJson.decode(last_response.body)

      post '/jobs/finish', MultiJson.encode(jobs), 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'
    end

    it 'should be ok' do
      expect(last_response).to be_ok
    end

    it 'should remove job from pending' do
      get '/jobs/pick', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      jobs = MultiJson.decode(last_response.body)

      post '/jobs/finish', MultiJson.encode(jobs)

      get '/jobs/pending', nil, {'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
      jobs = MultiJson.decode(last_response.body)
      expect(jobs.length).to eq(0)
    end
  end
end
