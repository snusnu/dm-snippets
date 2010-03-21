require 'rubygems'
require 'dm-core'
require 'pp'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :nullable => false, :length => 255
end

DataMapper.auto_migrate!

p = Person.create(:name => 'snusnu')
p.model.properties.each do |property|
  pp property.name
  pp property.type
  pp property.options
end

# mungo:snippets snusnu$ ruby krunar.rb 
#  ~ (0.000137) SELECT sqlite_version(*)
#  ~ (0.000109) DROP TABLE IF EXISTS "people"
#  ~ (0.000026) PRAGMA table_info("people")
#  ~ (0.000410) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(255) NOT NULL)
#  ~ (0.000053) INSERT INTO "people" ("name") VALUES ('snusnu')
# :id
# DataMapper::Types::Serial
# {:serial=>true, :min=>1}
# :name
# String
# {:length=>255, :nullable=>false}
