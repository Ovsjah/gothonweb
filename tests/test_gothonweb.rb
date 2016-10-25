require './bin/app.rb'
require 'test/unit'
require 'rack/test'

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_my_default
    get '/'
    assert_equal 'START', last_request.session[:room]
    assert last_response.original_headers["Location"].include?('/game')
  end
  
  def test_show_room
    get '/'
    get '/game'
    assert last_response.ok?
    assert last_response.body.include?('Central Corridor')
  end

  def test_you_died
    get '/game'
    assert last_response.ok?
    assert last_response.body.include?('You Died!')
  end
  
  def test_show_room_form_post
    post '/game', params={:action => 'tell a joke!'}
    assert last_response.ok?
    last_request.session[:room] = 'START'
    room = Map::load_room(last_request.session)
    next_room = room.go(params[:action])
    assert_equal Map::LASER_WEAPON_ARMORY, next_room
  end
  
  def test_you_died_form_post
    post '/game', params={:action => 'dodge!'}
    assert last_response.ok?
    last_request.session[:room] = 'START'
    room = Map::load_room(last_request.session)
    next_room = room.go(params[:action])
    assert_equal Map::GENERIC_DEATH, next_room
  end
end
