# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'plaid'
require "awesome_print"

#Settings
set :public_folder, 'public'

class Note < ActiveRecord::Base
end

# class Bank
# 	@@banks = nil

# 	def self.banks
# 		@@banks ||= Plaid.institution
# 		@@banks
# 	end

# 	def find

# 	end
# end


Plaid.config do |p|
    p.customer_id = '5573460e3b5cadf40371c33e'
    p.secret = 'cccf4e82dafff7c0e7267709cd3b1d'
	configure :development do
 		p.environment_location = 'https://tartan.plaid.com/'
	end
	configure :production do
 		p.environment_location = 'https://api.plaid.com/'
	end
end

configure :production, :development do
 db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/af')
end

get "/welcome" do
	erb :"welcome"
end

get '/banks' do
	@banks = Plaid.institution
  	erb :"banks/index"
end

get "/banks/:id" do
 @bank = Plaid.institution.find{|bank| bank.id == params[:id]}
 "bank name #{ @bank }"
 @user = Plaid.add_user('auth','plaid_test','plaid_good','wells')
 "user #{@user}"
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# AJAX endpoint that first exchanges a public_token from the Plaid Link
# module for a Plaid access token. That access_token is then used to
# retrieve account and balance data for a user using plaid-ruby.
get '/accounts' do
  # Pull the public_token from the querystring
  public_token = params[:public_token]

  # Exchange the Link public_token for a Plaid API access token
  exchange_token_response = Plaid.exchange_token(public_token)

  # Initialize a Plaid user
  user = Plaid.set_user(exchange_token_response.access_token, ['auth'])

  # Retrieve information about the user's accounts
  user.get('auth')

  # Transform each account object to a simple hash
  transformed_accounts = user.accounts.map do |account|
    {
      balance: {
        available: account.available_balance,
        current: account.current_balance
      },
      meta: account.meta,
      type: account.type
    }
  end

  # Return the account data as a JSON response
  content_type :json
  { accounts: transformed_accounts }.to_json
  # { accounts: transformed_accounts, txns: user.transactions }.to_json
end