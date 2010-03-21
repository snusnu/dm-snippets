require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

class Apple
  include DataMapper::Resource
  property :id,         Serial
  has n, :oranges, :through=>Resource  
end

class Orange
  include DataMapper::Resource
  property :id, Serial
  has n, :apples, :through=>Resource
end

DataMapper.auto_migrate!

Apple.create;  Apple.create;  Apple.create
Orange.create; Orange.create; Orange.create

a = Apple.get(1)
o = Orange.get(1)
a.oranges << o
a.save
a = Apple.get(2)
o = Orange.get(2)
a.oranges << o 
a.save

a = Apple.get(3)

o = Orange.get(1) # orange_1 is already in apple_1.oranges (doesn't end up in output - FAIL)
a.oranges<<o
a.save
o = Orange.get(2) # orange_2 is already in apple_2.oranges (doesn't end up in output - FAIL)
a.oranges << o
a.save
o = Orange.get(3) # orange_3 isn't part of any oranges collection yet (ends up in output - PASS)
a.oranges << o
a.save

Apple.all.each do |a|
  puts "apple_id = #{a.id}"
  a.oranges.each do |o|
    p "apple_#{a.id}.oranges = #{o.id}"
  end
end

# apple_id = 1
# "apple_1.oranges = 1"
# apple_id = 2
# "apple_2.oranges = 2"
# apple_id = 3
# "apple_3.oranges = 3"
