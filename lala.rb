require 'rubygems'
require 'dm-core'
require 'dm-validations' # IF this is left out, everything works

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :age, Integer, :required => true, :default => 30
end

Person.auto_migrate!

Person.create :age => ''

puts "Nr of persons: #{Person.all.size}"
