require 'sinatra'

enable :sessions
set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
  'Hello world'
end

get '/hello/' do
  erb :hello_form
end

post '/hello/' do
  hello = params[:greeting] || "Hi There"
  user = params[:name] || "Nobody"
  puts '[Params]'
  p params
  
  erb :index, :locals => {'greeting' => hello, 'name' => user}
end

get '/upload/' do
  erb :upload
end

get '/show_pic' do
  erb :show_pic
end

post '/after_upload/' do
  puts '[Params]'
  p params
  @filename = params['pic'][:filename]
  p @filename
  file = params['pic'][:tempfile]
  p file
  #File.open('static/' + params[:pic][:filename], "w") {|f| f.write(params[:pic][:tempfile].read)}
  File.open("static/#{@filename}", 'w') do |f|
    f.write(file.read)
  end
  erb :after_upload
end
