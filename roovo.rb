require 'rubygems'
require 'dm-core'
 
class User
  include DataMapper::Resource
  
  property :id, Serial
end
 
class Paper
  include DataMapper::Resource
  
  property :id, Serial
  
  has n, :author_joins
  has n, :authors, User, :through => :author_joins, :remote_name => :user, :target_key => [ :user_id ]
end
 
class AuthorJoin
  include DataMapper::Resource
  
  property :id, Serial
  property :user_id, Integer
  property :paper_id, Integer
  
  belongs_to :user
  belongs_to :paper
end
 
DataMapper.setup(:default, "sqlite3::memory:")
User.auto_migrate!
AuthorJoin.auto_migrate!
Paper.auto_migrate!
 
user = User.create!
paper = Paper.create!
paper.authors << user