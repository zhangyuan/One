require "sinatra/base"

class OneApp < Sinatra::Base
  get '/' do
    "hello"
  end
end
