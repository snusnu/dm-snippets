require 'rubygems'
require 'dm-core'
require 'dm-types'
 
 
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3::memory:") 
 
class Seating
  include DataMapper::Resource
 
  property :id, Serial
  property :days, Flag[:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
 
end
 
DataMapper.auto_upgrade!
 
s = Seating.create
p s

s.days = [:monday] 
s.save
p s
s.days = [:monday,:tuesday]
s.save
p s

s = Seating.first
p s
  
