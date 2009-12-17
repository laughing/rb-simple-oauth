require 'rubygems'
require 'haml'
require 'json'
require 'sinatra'

require 'simple-oauth'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
 
configure do
  use Rack::Session::Cookie
  CONSUMER_KEY = ''
  CONSUMER_SECRET = ''
  PROVIDER = 'http://twitter.com'
  COUNT = 10
end

template :layout do
  <<-EOF
!!! XML
!!! Strict
 
%html
  %head
    %title OAuth and Sinatra Sample
    %meta{:"http-equiv"=>"Content-Type", :content=>"text/html", :charset=>"utf-8"}
    %link{:rel=>"stylesheet", :type=>"text/css", :href=>"/style.css"}
  %body
    != yield
EOF
end

def simple_oauth
  SimpleOAuth.new(CONSUMER_KEY, CONSUMER_SECRET, @token, @token_secret)
end

def base_url
  default_port = (request.scheme == "http") ? 80 : 443
  port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
  "#{request.scheme}://#{request.host}#{port}"
end

error do
  'Error - ' + request.env['sinatra.error'].name
end

get '/' do
  redirect '/timeline' if session[:access_token]
  haml <<-EOF
<a href="/request_token">request_token</a>
EOF
end

get '/request_token' do
  callback = "#{base_url}/access_token"
  @token = ''
  @token_secret = ''
  request_token_url = PROVIDER + '/oauth/request_token'
  response = simple_oauth.request_token(request_token_url, callback)
  session[:request_token] = response[:token]
  session[:request_token_secret] = response[:secret]
  redirect response[:authorize]
end

get '/access_token' do
  @token = session[:request_token]
  @token_secret = session[:request_token_secret]
  access_token_url = PROVIDER + '/oauth/access_token'
  response = simple_oauth.access_token(access_token_url, params[:oauth_verifier])
  session[:access_token] = response[:token]
  session[:access_token_secret] = response[:secret]
  haml <<-EOF
<a href="/timeline">timeline</a>
EOF
end

get '/timeline' do
  @token = session[:access_token]
  @token_secret = session[:access_token_secret]
  timeline_url = PROVIDER + "/statuses/friends_timeline.json?count=#{COUNT}"
  response = simple_oauth.get(timeline_url)
  raise response.code unless response.code.to_i == 200
  @timeline = JSON(response.body)
  haml <<-EOF
%dl
 - @timeline.each do |status|
  %dt= status['user']['screen_name']
  %dd= status['text']
EOF
end
