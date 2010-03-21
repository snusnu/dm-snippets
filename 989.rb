require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, 'sqlite3:memory:')

class Post
  include DataMapper::Resource
  
  Page = "page"
  Post = "post"
  
  has n, :taggings
  has n, :tags, :through => :taggings

  property :id, Serial
  property :body, Text
  property :mtime, Time
  property :created, Time
  property :type, String, :default => Post
  property :url, String
end

class Tag
  include DataMapper::Resource 
  
  has n, :taggings
  has n, :posts, :through => :taggings
  
  property :id, Serial
  property :name, String
end

class Tagging
  include DataMapper::Resource 
  
  belongs_to :post
  belongs_to :tag
  
  property :id, Serial
end

DataMapper.auto_migrate!

one = Tag.create :name => 'one'
two = Tag.create :name => 'two'

first = Post.new
first.body = "This is a body"
first.mtime = Time.now
first.created = Time.now
first.type = Post::Post
first.url = "a/url"
first.save

second = Post.new
second.body = "Two"
second.mtime = Time.now
second.created = Time.now
second.type = Post::Post
second.url = "b/url"
second.save

first.tags << one
first.tags << two
first.save

one   = Post.first
posts = Post.all

puts "Post.first.tags = #{Post.first.tags.inspect}"
puts "posts[0].tags = #{posts[0].tags.inspect}"
puts "posts[1].tags = #{posts[1].tags.inspect}"

# mungo:snippets snusnu$ ruby 989.rb 
# Post.first.tags = [#<Tag @id=1 @name="one">, #<Tag @id=2 @name="two">]
# posts[0].tags = [#<Tag @id=1 @name="one">, #<Tag @id=2 @name="two">]
# posts[1].tags = []
