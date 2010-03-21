require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :name, String
end

Person.storage_names[:default] = 'people'
Person.auto_migrate!

Person.storage_names[:default] = 'humans'
Person.auto_migrate!

Person.storage_names[:default] = 'people'
Person.create(:name => 'person')

puts "Number of people: #{Person.all.size}"

Person.storage_names[:default] = 'humans'
Person.create(:name => 'human')

puts "Number of humans: #{Person.all.size}"

Person.first(:name => 'human')

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby storage_names.rb 
 ~ (0.000042) SELECT sqlite_version(*)
 ~ (0.000063) DROP TABLE IF EXISTS "people"
 ~ (0.000010) PRAGMA table_info("people")
 ~ (0.000269) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
 ~ (0.000012) DROP TABLE IF EXISTS "humans"
 ~ (0.000015) PRAGMA table_info("humans")
 ~ (0.000107) CREATE TABLE "humans" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
 ~ (0.000041) INSERT INTO "people" ("name") VALUES ('person')
 ~ (0.000025) SELECT "id", "name" FROM "people" ORDER BY "id"
Number of people: 1
 ~ (0.000043) INSERT INTO "humans" ("name") VALUES ('human')
 ~ (0.000023) SELECT "id", "name" FROM "humans" ORDER BY "id"
Number of humans: 1
 ~ (0.000031) SELECT "id", "name" FROM "humans" WHERE "name" = 'human' ORDER BY "id" LIMIT 1

