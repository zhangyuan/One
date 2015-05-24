require File.expand_path("../spec_helper", __FILE__)

describe 'worker' do
  before(:each) do
    Timecop.freeze Time.local(2015, 1, 1, 12, 0, 0)
    post 'jobs', MultiJson.encode({name: "jobs/name", params: {id: 1}}), {'Content-Type' => 'application/json', 'X-OneApp-Application-Key' => 'OneApp'}
    get '/jobs/pick', nil, 'X-OneApp-Application-Key' => 'OneApp'
  end

  after(:each) do
    Timecop.return
  end

  it "should pick expired job and put into ready with retry increase one" do
    Timecop.freeze Time.local(2015, 1, 1, 12, 10, 1)
    worker = OneApp::Worker.new
    worker.run

    get '/jobs/ready', nil, 'X-OneApp-Application-Key' => 'OneApp'
    jobs = MultiJson.decode(last_response.body)

    expect(jobs.length).to eq(1)
    expect(jobs[0]['name']).to eq('jobs/name')
    expect(jobs[0]['params']).to eq({'id' => 1})
    expect(jobs[0]['created_at']).to eq(Time.local(2015, 1, 1, 12, 0, 0).to_i)
    expect(jobs[0]['retry_times']).to eq(1)
  end
end
