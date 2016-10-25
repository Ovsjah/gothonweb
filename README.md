# gothonweb with sign up and log in forms
the final exam in the learn ruby the hard way course

# Audience
For those who wants multiple user authenication using Sinatra and DataMapper during the implemantation of the last project of the LRTHW book.

# User Authentication and DataBase
For User Authentication I used Warden. Also I used DataMapper for communicating with database (sqlite in our case) and sqlite adapter. Read about DataMapper there are many useful info there.

# The First Step
Let's get started on a User model. The first step is to install the gems we need.

Installing upstream gems is as easy as running gem install GEM_NAME command, however some gems might fail to install due to compilation errors:


$ sudo dnf install ruby-devel - I'm using Fedora so I need this 

$ sudo gem install data_mapper

$ sudo dnf install sqlite-devel - Also this to solve dependencies

$ sudo gem install dm-sqlite-adapter


When installing the data_mapper gem bcrypt-ruby is installed as a dependency

Create model.rb in your lib/gothonweb/ directory and require the gems and set up DataMapper

# The Second Step
I use bundler with Sinatra, this is the Gemfile for this example app. Before You'll need to create that Gemfile in your directory and run the following in Terminal: $ bundle install

# The Third Step
Create gothonweb.rb the main file for our app. Require all necessery files.

# The Fourth Step
Starting the App using shotgun. You can install it using sudo gem install shotgun. It is very useful gem because it'll pick up changes to your ruby files so you won't need to stop and restart server every time you change a file.
To use shotgun with our config.ru file, you need to tell shotgun which file to use, like so:

$ shotgun config.ru
