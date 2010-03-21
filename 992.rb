require 'rubygems'
require 'dm-core'
require 'dm-aggregates'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Retailer
  include DataMapper::Resource

  property :id, Serial

  has n, :sales
  has n, :items
  has n, :users
end

class Sale
  include DataMapper::Resource

  property :id, Serial
  
  belongs_to :retailer
end

class Item
  include DataMapper::Resource

  property :id, Serial

  belongs_to :retailer
end

class User
  include DataMapper::Resource

  property :id, Serial

  belongs_to :retailer
end

DataMapper.auto_migrate!

r1 = Retailer.create
r2 = Retailer.create

100.times do |i|
  Sale.create(:retailer => r1)
  Item.create(:retailer => r1)
  User.create(:retailer => r1)
end

100.times do |i|
  Sale.create(:retailer => r2)
  Item.create(:retailer => r2)
  User.create(:retailer => r2)
end

# the first retailer will SEL all sales, items, users
# which isn't much here, but can grow quite large
# when all that's needed is count
Retailer.all.each do |r|
  puts "--------------------------"
  puts r.sales.count
  puts r.items.count
  puts r.users.count
end
