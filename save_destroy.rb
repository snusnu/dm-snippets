require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id, Serial
  property :name, String
end

DataMapper.auto_migrate!

p = Person.create :name => 'snusnu'
p.name = 'robholland'

puts "dirty == #{p.dirty?.inspect}"
puts "saved == #{p.saved?.inspect}"

puts "Destroying ..."
p.destroy

puts "new   == #{p.new?.inspect}"
puts "saved == #{p.saved?.inspect}"

puts "destroyed == #{(!p.saved? && !p.new?).inspect}"

__END__

mungo:snippets snusnu$ ruby save_destroy.rb 
 ~ (0.000129) SELECT sqlite_version(*)
 ~ (0.000095) DROP TABLE IF EXISTS "people"
 ~ (0.000029) PRAGMA table_info("people")
 ~ (0.000363) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
 ~ (0.000055) INSERT INTO "people" ("name") VALUES ('snusnu')
dirty == true
saved == true
