require 'bundler'
Bundler.require

require './lib/gothonweb/model.rb'
require './lib/gothonweb/map.rb'

class GothonwebApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  set :session_secret, 'killemall'

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id}
    config.serialize_from_session{|id| User.get(id)}
    
    config.scope_defaults :default,
      strategies: [:password],
      action: '/unauthenticated'
    config.failure_app = self
  end
  
  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
    env.each do |key, value|
      env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
    end
  end
  
  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end
    
    def authenticate!
      user = User.first(username: params['user']['username'])
      
      if user.nil?
        throw(:warden, message: "The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        throw(:warden, message: "The username and password combination")
      end
    end
  end
  
  get '/' do
    session[:room] = 'START'
    redirect '/game'
  end
  
  get '/game' do
    env['warden'].authenticate!
    room = Map::load_room(session)
    
    if room
      erb :show_room, :locals => {:room => room}
    else
      erb :you_died
    end
  end
  
  post '/game' do
    room = Map::load_room(session)
    action = params[:action]
    if room
      next_room = room.go(action) || room.go("*")
      
      if next_room
        Map::save_room(session, next_room)
      end
      
      redirect '/game'
    else
      erb :you_died
    end
  end
  
  get '/login' do
    erb :login
  end
  
  post '/login' do
    env['warden'].authenticate!
    
    flash[:success] = "Successfully logged in"
    
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end
  
  get '/register' do
    erb :register
  end
  
  post '/register' do
    if params['user']['password'] != params['user']['password_again']
      flash[:error] = "Passwords didn't match"
    elsif params['user']['username'] && params['user']['password'] == ""
      flash[:error] = "Fill out this form to continue!"
      redirect '/register'
    else
      flash[:seccess] = "Successfully registered. Log in to continue!"
      user = User.new(:username => params['user']['username'], :password => params['user']['password'])
      user.save
    end
    redirect '/login'
  end
  
  get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end  
  
  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attemted_path] if session[:return_to].nil?
    
    flash[:error] = env['warden.options'][:message] || "You must log in"
    redirect '/login'
  end
end
