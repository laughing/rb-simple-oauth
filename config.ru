require 'rubygems'
require 'appengine-rack'
require 'sample'

AppEngine::Rack.configure_app(
        :application => 'oauth_sinatra_sample',
        :version => 1
)

run Sinatra::Application
