#!/usr/bin/env ruby
# coding: utf-8

require 'simple-oauth'
require 'rubygems'
require 'json'
require 'readline'

# ここを置き換える
CONSUMER_KEY = 'CONSUMER-KEY'
CONSUMER_SECRET = 'CONSUMER-SECRET'
TOKEN = 'ACCESS-TOKEN'
TOKEN_SECRET = 'ACCESS-TOKEN-SECRET'

simple_oauth = SimpleOAuth.new(CONSUMER_KEY, CONSUMER_SECRET, TOKEN, TOKEN_SECRET)

# 認証してから 
# Tweetの投稿
response = simple_oauth.request_token('http://twitter.com/oauth/request_token')
puts "access PIN => " + response[:authorize]
response = simple_oauth.access_token('http://twitter.com/oauth/access_token', Readline.readline('PIN > ').strip)
response = simple_oauth.post('http://twitter.com/statuses/update.json', {
                              :status => Readline.readline('update status > ').strip})
raise "Request failed: #{response.code}" unless response.code.to_i == 200
# TimeLineの取得
response = simple_oauth.get('http://twitter.com/statuses/friends_timeline.json?count=5')
raise "Request failed: #{response.code}" unless response.code.to_i == 200
JSON.parse(response.body).each do |status|
  puts "#{status['user']['screen_name']}: #{status['text']}"
end
