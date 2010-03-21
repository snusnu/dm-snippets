require "rubygems"
require "dm-core"
require "dm-serializer"

class Test
  include DataMapper::Resource
  
  property :id,             Serial
  property :title,          String, :length => 1..255
  property :url,            String, :length => 1..255  

end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/test.db")
DataMapper.auto_migrate!

Test.create( :title => "hello there" , :url => "http stuff" ).to_yaml
