require "rubygems"
require "dm-core"
require "dm-serializer"

class Item
  include DataMapper::Resource
  
  property :id,               Serial
  property :title,            String
  property :kind,             Integer
  property :content,          Text  
    
end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
DataMapper.auto_migrate!

0.upto(100) do |i| 
  item = Item.create( :title => "item#{i}" , :content => "bla blab la " , :kind => ( rand() > 0.5 ? 1 : 2 ) )
end

as = Item.all( :kind => 1 )
bs = Item.all( :kind => 2 )

merged = as.concat( bs )

puts "Merged: #{merged.size}" # => 101

puts "Without json: #{merged.map { |item| item }.size}" # => 101
puts "With json: #{merged.map { |item| item.to_json }.size} (should be 101)" # => ~50