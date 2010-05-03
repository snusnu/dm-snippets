require 'dm-core'

DataMapper::Logger.new($stdout, :debug)

require 'dm-migrations' if ENV['BEFORE_SETUP']
DataMapper.setup(:default, 'sqlite3::memory:')
require 'dm-migrations' if ENV['AFTER_SETUP']

class Person
  include DataMapper::Resource
  property :id, Serial
end

DataMapper.auto_migrate!

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ BEFORE_SETUP=true ruby migrations_test.rb 
 ~ (0.000042) SELECT sqlite_version(*)
 ~ (0.000067) DROP TABLE IF EXISTS "people"
 ~ (0.000011) PRAGMA table_info("people")
 ~ (0.000271) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)

 ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ AFTER_SETUP=true ruby migrations_test.rb 
  ~ (0.000042) SELECT sqlite_version(*)
  ~ (0.000071) DROP TABLE IF EXISTS "people"
  ~ (0.000010) PRAGMA table_info("people")
  ~ (0.000258) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
