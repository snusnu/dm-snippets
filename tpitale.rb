require 'rubygems'
require 'dm-core'
 
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')
 
class Sale
  include DataMapper::Resource
 
  property :id, Serial
  
  belongs_to :user
  
  has n, :sale_items
  has n, :items, :through => :sale_items
end
 
class SaleItem
  include DataMapper::Resource
 
  property :id, Serial
 
  belongs_to :sale
  belongs_to :item
end
 
class Item
  include DataMapper::Resource
 
  property :id, Serial
 
  has n, :sale_items
end
 
class User
  include DataMapper::Resource
 
  property :id, Serial
 
  has n, :sales
  has n, :sale_items, :through => :sales
  # has n, :items, :through => :sale_items
end
 
Sale.auto_migrate!
# Sale is fine here
puts Sale.new.inspect
 
DataMapper.auto_migrate!
 
# Sale now has sale_item_id
puts Sale.new.inspect
