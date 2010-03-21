# This script demonstrates major performance problems when enabling the dm-timestamps plugin in 
# DataMapper 0.10.2.
require 'rubygems'
require 'dm-core'
 
DataMapper.setup(:default, 'sqlite3::memory:')
 
class City
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :updated_at, DateTime
  has n, :buildings
end
 
class Building
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :updated_at, DateTime
  belongs_to :city
  has n, :residents
end
 
class Resident
  include DataMapper::Resource
  property :id, Serial
  belongs_to :building
end
 
 
DataMapper.auto_migrate!
 
san_francisco = City.create(:name => "San Francisco")
transamerica_pyramid = san_francisco.buildings.new(:name => "TransAmerica Pyramid")
100.times {|n| transamerica_pyramid.residents.new }
t = Time.now
transamerica_pyramid.save
without_timestamps = Time.now.to_f - t.to_f
 
require 'dm-timestamps'
coit_tower = san_francisco.buildings.new(:name => "Coit Tower")
100.times {|n| coit_tower.residents.new }
t = Time.now
coit_tower.save
with_timestamps = Time.now.to_f - t.to_f
 
puts "without dm-timestamps required, creating 100 subnodes takes #{without_timestamps} seconds"
puts "with dm-timestamps required, creating 100 subnodes takes #{with_timestamps} seconds"
puts "slowdown: #{with_timestamps / without_timestamps}x"
