require 'rubygems'
require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, 'postgres://localhost/af')

get '/' do
  "Hello, World!"
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :home

end

post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  erb :edit
end

put '/:id' do
  n = Note.get params[:id]
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/about' do
  'A little about me.'
end

get '/form' do
  erb :form
end

post '/form' do
  "You said '#{params[:message]}'"
end

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end
 
DataMapper.finalize.auto_upgrade!