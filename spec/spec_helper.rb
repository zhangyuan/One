require File.expand_path('../../config/boot', __FILE__)
Bundler.require(:test)

require File.expand_path("../../app.rb", __FILE__)

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app; OneApp end
end

RSpec.configure { |c| c.include RSpecMixin }
