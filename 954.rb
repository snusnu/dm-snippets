require 'rubygems'
require 'dm-core'

class Person
  include DataMapper::Resource
  
  property :id, Serial
  
  property :name, String

  has n, :things
end

class Thing
  include DataMapper::Resource
  
  property :id, Serial
  
  property :name, String

  belongs_to :person
end

#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default,"sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/test.db")
DataMapper.auto_migrate!


puts '------- This works -------------------------------------'

person = Person.new(:name => 'This is a person')
person.save
puts "\tPerson: \t\t"        + person.inspect

person.things.new(:person => person, :name => 'Something...')
person.save

puts "\tThing:  \t\t"        + person.things.last.inspect
puts "\tPerson's Things: \t" + person.things.inspect

person.things.new(:person => person, :name => 'Something else...')
person.save

puts "\tThing:  \t\t"        + person.things.last.inspect
puts "\tPerson's Things: \t" + person.things.inspect


