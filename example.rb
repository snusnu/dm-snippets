require 'rubygems' 
require 'dm-core' 
require 'dm-validations' 
require 'dm-timestamps' 

DataMapper::Logger.new(STDERR, :debug) 
DataMapper.setup(:default, 'sqlite3://:memory:') 

class Post 
  include DataMapper::Resource 
  property :id,         Serial
  property :name,       String 
  property :title,      String 
  property :body,       Text 
  property :created_at, DateTime 

  has n, :comments 
  has n, :categorizations 
  has n, :categories, :through => :categorizations 
end 

class Comment 
  include DataMapper::Resource 
  property :id,         Serial 
  property :post_id,    Integer
  property :posted_by,  String 
  property :email,      String 
  property :url,        String 
  property :body,       Text 

  belongs_to :post
end 

class Category 
  include DataMapper::Resource 
  property :id,         Serial
  property :name,       String 

  has n, :categorizations 
  has n, :posts, :through => :categorizations 
end 

class Categorization 
  include DataMapper::Resource 
  property :id,          Serial 
  property :post_id,     Integer
  property :category_id, Integer
  property :created_at,  DateTime

  belongs_to :category 
  belongs_to :post 
end 

DataMapper.auto_migrate! 

post = Post.create(:title => 'first post', :body => 'first post body')  
post.comments.build(:body => 'comment') 
post.save
post.categories.build(:name => 'tag') 
post.save

