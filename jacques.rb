require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug) 
DataMapper.setup(:default, 'sqlite3::memory:')

class Post
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, Text
  
  def self.alphabetical
    all(:order => [:name.desc])
  end
  
  def self.with_name
    all(:name.not => nil)
  end
  
  def self.by_body(body)
    all(:description.like => "%#{body}%")
  end
  
end

Post.auto_migrate!

puts Post.alphabetical.with_name.by_body("blah").inspect