require 'rubygems'
require 'dm-core'
require 'dm-serializer'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Post
  
  include DataMapper::Resource
  
  property :id,      Serial  
  property :body,    String
  
  belongs_to :wall
  
end


class Wall
  
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String,  :nullable => false, :length => (1..255)

  has n, :posts

end

DataMapper.auto_migrate!

wall = Wall.create :name => 'linzblast', :posts => [ Post.new(:body => 'has'), Post.new(:body => 'bugs') ]

require 'pp'
pp wall.to_json({
  :only => [ :id, :name ],
  :relationships => [ :posts => { :include => [ :id, :body ] } ]
})