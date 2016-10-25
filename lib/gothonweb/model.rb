require 'rubygems'
require 'data_mapper'    # object-relational mapper (maps object to database)
require 'dm-sqlite-adapter'    # adapter that allows DataMapper to communicate to the Database
require 'bcrypt'    # password hashing function

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")  # specifying my database connection


class User
  include DataMapper::Resource
  # Creating properties in object for the Database
  property :id, Serial, :key => true
  property :username, String, :length => 3..50
  property :password, BCryptHash   # property stores hashed password with bcrypt
  property :room, String, :length => 3..50  # property stores room in the object
  
  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

DataMapper.finalize  # finalizating model after declaring this checks the model for validity and initializes all properties associated with relationships
DataMapper.auto_upgrade!  # creating new tables and adds columns to existing tables. It doesn't change any existing columns and doesn't drop any columns
# @user is a resource an instance of a model. @user = User.new(:username => "admin", :password => "test") then we should save it @user.save
