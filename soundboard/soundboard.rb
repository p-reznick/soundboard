require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @users = {
    'Peter' => 'Reznick',
    'Emma' => 'Reznick',
    'Pamela' => 'Reznick',
    'Robert' => 'Reznick',
  }
end

configure do
  enable :sessions
  set :session_secret, 'super_secret'
end

def require_signed_in_user
  return true if session[:user]
  false
end

def valid_credentials?(username, password)
  if @users[username] == password
    session[:user] = username
    session[:message] = "Welcome to your sound board #{username}!"
    return true
  else
    session[:message] = "Invalid credentials."
    return false
  end
end

def read_users
  session[:users] = YAML.open_file(File.open("./data/users.yml", "r"))
end

def write_users
  File.open("./data/users.yml", "w") { |f| f.write(session[:users].to_yaml) }
end

def require_signed_in_user
  redirect "/signin" unless session[:user]
end

get '/' do
  require_signed_in_user
  erb :index
end

get '/signin' do
  erb :signin
end

post '/signin' do
  redirect '/' if valid_credentials?(params[:username], params[:password])
  session[:message] = "Sorry, invalid credentials."
  redirect '/'
end

get '/sign_out' do
  session.delete(:user)
  redirect '/'
end

get '/boards/mad_money' do
  require_signed_in_user
  erb :mad_money
end

get '/boards/pulp_fiction' do
  require_signed_in_user
  erb :pulp_fiction
end

get '/boards/monty_python' do
  require_signed_in_user
  erb :monty_python
end

get '/data/:directory/:file_name' do
  dir = params[:directory]
  file = params[:file_name]
  File.open("./data/#{dir}/#{file}")
end