require 'rubygems'
require 'appengine-rack'
require 'sample'

AppEngine::Rack.configure_app(
        :application => 'sample_app',
        :version => 1
)

run Sinatra::Application
