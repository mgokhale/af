require 'bundler'
Bundler.require
require './basics'
 
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/af')
run Sinatra::Application