require File.expand_path("../spec_helper", __FILE__)

describe 'worker' do
  before(:each) do
    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
  end

  after(:each) do
    Timecop.return
  end

  it "should pick expired job and put into ready while increasing retry times" do
    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
    post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
    get '/jobs/pick', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'

    Timecop.freeze Time.local(2015, 1, 1, 12, 10, 1)
    worker = OneApp::Worker.new
    worker.run

    get '/jobs/ready', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'
    jobs = MultiJson.decode(last_response.body)

    expect(jobs.length).to eq(1)
    expect(jobs[0]['name']).to eq('jobs/name')
    expect(jobs[0]['params']).to eq({'id' => 1})
    expect(jobs[0]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
    expect(jobs[0]['retry_times']).to eq(1)
  end

  it "should pick expired job with specific limit and put into ready while increasing retry times" do
    post 'jobs', MultiJson.encode({name: "jobs/name1", params: {id: 1}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
    post 'jobs', MultiJson.encode({name: "jobs/name2", params: {id: 2}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
    post 'jobs', MultiJson.encode({name: "jobs/name3", params: {id: 3}}), {'Content-Type' => 'application/json', 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'}
   
    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
    get '/jobs/pick', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'

    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 10)
    get '/jobs/pick', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'

    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 20)
    get '/jobs/pick', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'

    Timecop.freeze Time.local(2015, 1, 1, 12, 10, 12)
    worker = OneApp::Worker.new
    worker.run(limit: 2)

    get '/jobs/ready', nil, 'HTTP_X_ONEAPP_APPLICATION_KEY' => 'OneApp'
    jobs = MultiJson.decode(last_response.body)

    expect(jobs.length).to eq(2)
    expect(jobs[0]['name']).to eq('jobs/name1')
    expect(jobs[0]['params']).to eq({'id' => 1})
    expect(jobs[0]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
    expect(jobs[0]['retry_times']).to eq(1)


    expect(jobs[1]['name']).to eq('jobs/name2')
    expect(jobs[1]['params']).to eq({'id' => 2})
    expect(jobs[1]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
    expect(jobs[1]['retry_times']).to eq(1)
  end
end
