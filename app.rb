# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'


class Note < ActiveRecord::Base
end

get "/welcome" do
	"welcome"
end

get "/" do
  @notes = Note.order("created_at DESC")
  @title = "Welcome."
  erb :"notes/index"
end


