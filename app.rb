require File.expand_path('../config/boot', __FILE__)

class OneApp < Sinatra::Base
  before do
    content_type 'application/json'
  end

  get '/' do
    "hello"
  end

  get '/jobs' do
    builder = Jbuilder.new do |json|
      json.array!([1]) do
        json.name "jobs/name"
        json.params do
          json.id 1
        end
      end
    end

    builder.target!
  end

  post '/jobs' do
  end
end
