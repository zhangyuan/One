require File.expand_path('../../config/boot', __FILE__)
Bundler.require(:test)

require File.expand_path("../../app.rb", __FILE__)

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app 
    OneApp::App.set :root, File.expand_path('../../', __FILE__)
    OneApp::App 
  end
end

RSpec.configure { |c| c.include RSpecMixin }
