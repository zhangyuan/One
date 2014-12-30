require File.expand_path("../spec_helper", __FILE__)

describe "/" do
  it 'should be ok' do
    get '/'
    expect(last_response).to be_ok
  end
end
