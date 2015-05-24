require File.expand_path("../app", __FILE__)

OneApp::App.set :root, File.dirname(__FILE__)

run OneApp::App
