require 'rubygems'
require 'dm-core'
require 'dm-validations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => (1..255)
end

DataMapper.auto_migrate!

p = Person.new :name => ''

puts p.valid?

__END__

mungo:snippets snusnu$ ruby slaskis.rb 
 ~ (0.000074) SELECT sqlite_version(*)
 ~ (0.003698) DROP TABLE IF EXISTS "people"
 ~ (0.000028) PRAGMA table_info("people")
 ~ (0.006758) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(255))
slaskis.rb:17: undefined method `valid?' for #<Person @id=nil @name=""> (NoMethodError)
mungo:snippets snusnu$ ruby slaskis.rb 
 ~ (0.000037) SELECT sqlite_version(*)
 ~ (0.003698) DROP TABLE IF EXISTS "people"
 ~ (0.000022) PRAGMA table_info("people")
 ~ (0.003534) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(255))
true
