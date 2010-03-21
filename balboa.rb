require 'rubygems'
require 'dm-core'
require 'dm-constraints'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'mysql://localhost/dm_core_test')

class Comment
  include DataMapper::Resource
  
  property :id,          Serial
  property :name,        String

  has n, :categories, :through => Resource, :constraint => :destroy!

end

class Category
  include DataMapper::Resource
  
  property :id,          Serial
  property :name,        String

  has n, :comments, :through => Resource, :constraint => :destroy!

end

DataMapper.auto_migrate!
DataMapper.auto_migrate!
