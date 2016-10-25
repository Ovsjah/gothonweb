require 'bundler'
Bundler.require

require './lib/gothonweb/model.rb'
require './lib/gothonweb/map.rb'
require './lib/gothonweb/lexicon.rb'
require './lib/gothonweb/parser.rb'

class GothonwebApp < Sinatra::Base    # creates a new Sinatra app and
  enable :sessions                    # registers session support and
  register Sinatra::Flash             # the flash messages
  set :session_secret, 'killemall'
  # Warden setup block
  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id}
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id)}
    
    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: '/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end
  
  Warden::Manager.before_failure do |env,opts|
    # Because authentication failure can happen on any request but
    # we handle it only under "post '/auth/unauthenticated'", we need
    # to change request to POST
    env['REQUEST_METHOD'] = 'POST'
    # And we need to do the following to work with Rack::MethodOverride
    env.each do |key, value|
      env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
    end
  end
  # Block for the :password strategy we called above
  Warden::Strategies.add(:password) do
    def valid?    # acts as guard for the strategy it'll be tried if #valid? evaluates to true
      params['user'] && params['user']['username'] && params['user']['password']
    end
    
    def authenticate!    # the logic for authenticating my request
      user = User.first(username: params['user']['username'])  # a datamapper method that finds first matching record with the name params['user']['username']
      
      if user.nil?
        throw(:warden, message: "The username you entered does not exist")
      elsif user.authenticate(params['user']['password'])  # we created authenticate method in our model.rb file in User class that accepts an attempted password
        success!(user)
      else
        throw(:warden, message: "The username and password combination")
      end
      
    end
  end
  
  get '/' do
    user = User.get(session['warden.user.default.key'])  # gets user from our database

    if user && session[:room] == 'GENERIC_DEATH' || session[:room] == 'THE_END_WINNER' || session[:room] == 'THE_END_LOSER'
      session[:room] = 'START'
    elsif user && user[:room] != nil
      session[:room] = user[:room]
    else
      session[:room] = 'START'
    end
    
    redirect '/game'
  end
  
  get '/game' do
    env['warden'].authenticate!   # this is our protected page
    room = Map::load_room(session)
    p room.paths.keys
    p session[:room]
    session[:code] = room.paths.keys[0]  # this is where I stored randomly generated key for the next room object
    session[:guesses] = 10
    p session[:code]
    if room
      erb :show_room, :locals => {:room => room}
    else
      erb :you_died
    end
  
  end
  
  post '/game' do
    action = params[:action]

    if session[:room] == 'LASER_WEAPON_ARMORY' && action == session[:code]
      next_room = Map::THE_BRIDGE
      Map::save_room(session, next_room)
      redirect '/game'
    elsif session[:room] == 'LASER_WEAPON_ARMORY' && action != session[:code] && session[:guesses] > 1
      session[:guesses] -= 1
      p session[:guesses]
      room = Map::load_room(session)
      erb :show_room, :locals => {:room => room}
    elsif session[:room] == 'ESCAPE_POD' && action == session[:code]
      next_room = Map::THE_END_WINNER 
      Map::save_room(session, next_room)
      redirect '/game'
    elsif session[:room] == 'ESCAPE_POD' && action != session[:code]
      room = Map::load_room(session)
      next_room = room.go("*")
      Map::save_room(session, next_room)
      redirect '/game'
    else
      room = Map::load_room(session)
      
      if room && room.name != 'Laser Weapon Armory' && room.name != 'Escape Pod'
        scanned = Lexicon.scan(action)
        edited = Parser.new.parse_sentence(scanned).edit
        p edited
        next_room = room.go(edited) || room.go("*")
        
        if next_room
          Map::save_room(session, next_room)
        end
        
        redirect '/game'
      else
        erb :you_died
      end
        
    end
  
  end
    
  get '/login' do
    erb :login
  end
  
  post '/login' do
    env['warden'].authenticate!  # authentication with Warden
    
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
      redirect '/register'
    elsif params['user']['username'] && params['user']['password'] == ""
      flash[:error] = "Fill out this form to continue!"
      redirect '/register'
    else
      user = User.new(:username => params['user']['username'], :password => params['user']['password'])
      user.save
      flash[:success] = "Successfully registered. Log in to continue!"
    end
    redirect '/login'
  end
  
  get '/logout' do
    user = User.get(session['warden.user.default.key'])
    if user
      user.update(:room => session[:room])  # updating room property in our User object with session's room
      env['warden'].raw_session.inspect
      env['warden'].logout
      flash[:success] = 'Successfully logged out'
      redirect '/'
    else
      redirect '/'
    end
  end  
  
  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attemted_path] if session[:return_to].nil?
    # Set the error and use a fallback if the message is not defined
    flash[:error] = env['warden.options'][:message] || "You must log in"
    redirect '/login'
  end
end
