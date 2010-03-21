require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3:memory:")

class Root
  include DataMapper::Resource
 
  property :id, Serial
 
  has n, :nodes
 
  def all_valid_items
    nodes.map {|n| n.valid_items }.flatten
  end
end
 
class Node
  include DataMapper::Resource

  property :id, Serial
 
  belongs_to :root
  has n, :items
 
  def valid_items
    items :value.not => nil
  end
end

class Item
  include DataMapper::Resource
  
  belongs_to :node
  
  property :id, Serial
  property :value, String, :lazy => false
end


DataMapper.auto_migrate!

r = Root.create
n = r.nodes.create
n1 = r.nodes.create

[nil,1,nil,1,1,1,nil].each do |val|
  n.items.create :value => val
  n1.items.create :value => val
end

puts r.all_valid_items.size #=> 14

# QUERY:
# ~ (0.000114) SELECT "id", "root_id" FROM "nodes" WHERE "root_id" = 1 ORDER BY "id"
# ~ (0.000106) SELECT "id", "value", "node_id" FROM "items" WHERE "node_id" IN (1, 2) ORDER BY "id"


# This should print out 8 (the number of records with a non-nil value)
# The bug only occurs when there is a :lazy => false attribute one of the models
# If we change Item to:

class Item
  include DataMapper::Resource
  
  belongs_to :node
  
  property :id, Serial
  property :value, String
end

# Then everything works as expected:

puts r.all_valid_items.size #=> 8

# QUERY:

# ~ (0.000083) SELECT "id", "node_id" FROM "items" WHERE "node_id" IN (1, 2) ORDER BY "id"
# ~ (0.000076) SELECT "id", "node_id" FROM "items" WHERE "value" <> 'BAgw' AND "node_id" = 1 ORDER BY "id"
# ~ (0.000054) SELECT "id", "node_id" FROM "items" WHERE "value" <> 'BAgw' AND "node_id" = 2 ORDER BY "id"