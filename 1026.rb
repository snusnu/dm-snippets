require 'rubygems'
require 'dm-core'
require 'dm-types'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Location
  include DataMapper::Resource

  property :id,    String, :key => true
  property :name,  String
  property :zones, Csv

end

DataMapper.auto_migrate!
