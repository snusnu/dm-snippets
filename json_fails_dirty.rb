# Json type fails to mark as dirty after changes.

require "rubygems"
require "dm-core"
require "dm-types"

class Item
  include DataMapper::Resource
  property :id,   Serial
  property :data, Json, :lazy => false
end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
DataMapper.auto_migrate!

a = Item.new
a.data = {
  :val1 => 10,
  :val2 => 20
}
puts "\nSaving 'a' with #{a.data.inspect}."
a.save
a.data.class # => Hash

puts "\nChanging data 'a.data[:val1]' from #{a.data[:val1]} to 30."
a.data[:val1] = 30
puts "Is a dirty? : #{a.dirty?}"   # => false  (SHOULD BE true)
puts "Calling a.save"
a.save    # => true, but fails to update record because it is incorrectly marked as dirty

puts "Local value: #{a.data.inspect}."
puts "DB value   : #{Item.last.data.inspect}."

