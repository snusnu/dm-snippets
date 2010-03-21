require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
end

class Profile
  include DataMapper::Resource
  property :id, Serial
  property :person_id, Integer
  belongs_to :person
end

DataMapper.auto_migrate!

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby blabla.rb 
 ~ (0.000038) SELECT sqlite_version(*)
 ~ (0.000059) DROP TABLE IF EXISTS "people"
 ~ (0.000013) DROP TABLE IF EXISTS "profiles"
 ~ (0.000016) PRAGMA table_info("people")
 ~ (0.000259) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000008) PRAGMA table_info("profiles")
 ~ (0.000095) CREATE TABLE "profiles" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "person_id" INTEGER)
