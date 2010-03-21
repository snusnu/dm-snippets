require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/test')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :foo, Integer, :max => 5
end

DataMapper.auto_migrate!
