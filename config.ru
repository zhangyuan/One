require File.expand_path("../app", __FILE__)

root = File.dirname(__FILE__)
config_path = File.join(root, 'config', 'application.yml')

OneApp::App.set :root, root
OneApp::App.set :one_config, OneApp::Config.new(YAML.parse_file(config_path).to_ruby)

run OneApp::App

