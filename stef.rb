require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
end

DataMapper.auto_migrate!

p = Person.new
p.save

puts "p.id = #{p.id}"

__END__

ree-1.8.7-2010.01 mungo:snippets snusnu$ ruby stef.rb 
 ~ (0.000044) SELECT sqlite_version(*)
 ~ (0.000072) DROP TABLE IF EXISTS "people"
 ~ (0.000012) PRAGMA table_info("people")
 ~ (0.000280) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000043) INSERT INTO "people" DEFAULT VALUES
p.id = 1
