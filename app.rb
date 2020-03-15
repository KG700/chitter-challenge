require 'sinatra/base'
require 'sinatra/flash'
require 'uri'
require './database_connection_setup'
require './lib/user'
require './lib/peep'

class Chitter < Sinatra::Base

  enable :sessions
  register Sinatra::Flash

  get '/peeps' do
    # fetch the user from the database, using an ID stored in the session
    @user = User.find(session[:user_id])
    @peeps = Peep.all
    p @peeps
    erb :index
  end

  get '/peeps/new' do
    Peep.create(peep: params[:peep], user_id: session[:user_id])
    redirect '/peeps'
  end

  get '/users/new' do
    # sign_up form:
    erb :"users/new"
  end

  post '/users' do
    user = User.create(name: params[:name], email: params[:email], password: params[:password])
    session[:user_id] = user.id
    redirect '/peeps'
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end

  post '/sessions' do
    user = User.authenticate(email: params[:email], password: params[:password])

    if user
      session[:user_id] = user.id
      redirect '/peeps'
    else
      flash[:notice] = 'Please check your email or password.'
      redirect '/sessions/new'
    end
  end

  post '/sessions/destroy' do
    session.clear
    flash[:notice] = "You have signed out."
    redirect '/peeps'
    # "HELLO"
  end

  run! if app_file == $0
end
