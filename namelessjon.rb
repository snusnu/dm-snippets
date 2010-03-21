#!/usr/bin/env ruby
#
# A one file test to show ...
require 'rubygems'
require 'dm-core'
require 'dm-validations'
 
# setup the logger
DataMapper::Logger.new(STDOUT, :debug)
 
# connect to the DB
DataMapper.setup(:default, 'sqlite3::memory:')
 
class User
  include DataMapper::Resource
 
  # properties
  property :id, Serial
  property :username, String
  property :password, String, :length => 10..50
 
  has 1..n, :pages
 
end
 
class Page
  include DataMapper::Resource
 
  # properties
  property :id, Serial
  property :name, String
 
  belongs_to :user
end
 
DataMapper.auto_migrate!
 
def save_without_transaction(username, password)
  @user = User.new(:username => username, :password => password, :pages => [ Page.new(:name => 'a'*51) ])

  if @user.save
    puts "YAY!"
    true
  else
    puts "BOO!"
    puts @user.errors.full_messages.join("\n")
    @user.pages.map { |p| puts(p.errors.full_messages.join("\n")) }
  end
end
 
 
puts "All users:"
p User.all
puts "All pages:"
p Page.all
 
 
save_without_transaction('namelessjon', 'rlyrlysecret!')
 
puts "All users:"
p User.all
puts "All pages:"
p Page.all
 
 
save_without_transaction('namedjon', 'notsogood')
 
puts "All users:"
p User.all
puts "All pages:"
p Page.all

