require "rubygems"
require "bundler"

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

Bundler.require(:default)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "one_app/config"
require "one_app/redis_connection"
require "one_app/job_manager"
require "one_app/job"
require "one_app/worker"
