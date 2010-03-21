require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id,    Serial
  property :name , String, :required => true
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target
end

class Friendship
  include DataMapper::Resource
  belongs_to :source, 'Person', :key => true
  belongs_to :target, 'Person', :key => true
end

DataMapper.auto_migrate!

Person.create(:name => 'Fry', :friends => [
  Person.create(:name => 'Bender'), # you can also just call Person.new
  Person.create(:name => 'Leela')   # you can also just call Person.new
])

puts "Fry's friends: #{Person.first(:name => 'Fry').friends.map(&:name).join(',')}"

__END__

ree-1.8.7-2010.01 mungo:snippets snusnu$ ruby srmtm.rb 
 ~ (0.000040) SELECT sqlite_version(*)
 ~ (0.000056) DROP TABLE IF EXISTS "people"
 ~ (0.000019) DROP TABLE IF EXISTS "friendships"
 ~ (0.000011) PRAGMA table_info("people")
 ~ (0.000261) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50) NOT NULL)
 ~ (0.000008) PRAGMA table_info("friendships")
 ~ (0.000126) CREATE TABLE "friendships" ("target_id" INTEGER NOT NULL, "source_id" INTEGER NOT NULL, PRIMARY KEY("target_id", "source_id"))
 ~ (0.000080) CREATE INDEX "index_friendships_source" ON "friendships" ("source_id")
 ~ (0.000076) CREATE INDEX "index_friendships_target" ON "friendships" ("target_id")
 ~ (0.000033) INSERT INTO "people" ("name") VALUES ('Bender')
 ~ (0.000034) INSERT INTO "people" ("name") VALUES ('Leela')
 ~ (0.000052) INSERT INTO "people" ("name") VALUES ('Fry')
 ~ (0.000064) SELECT "target_id", "source_id" FROM "friendships" WHERE ("target_id" = 1 AND "source_id" = 3) ORDER BY "target_id", "source_id" LIMIT 1
 ~ (0.000079) INSERT INTO "friendships" ("target_id", "source_id") VALUES (1, 3)
 ~ (0.000062) SELECT "target_id", "source_id" FROM "friendships" WHERE ("target_id" = 2 AND "source_id" = 3) ORDER BY "target_id", "source_id" LIMIT 1
 ~ (0.000062) INSERT INTO "friendships" ("target_id", "source_id") VALUES (2, 3)
 ~ (0.000040) SELECT "id", "name" FROM "people" WHERE "name" = 'Fry' ORDER BY "id" LIMIT 1
 ~ (0.000124) SELECT "people"."id", "people"."name" FROM "people" INNER JOIN "friendships" ON "people"."id" = "friendships"."target_id" INNER JOIN "people" "people_1" ON "friendships"."source_id" = "people_1"."id" WHERE "friendships"."source_id" = 3 GROUP BY "people"."id", "people"."name" ORDER BY "people"."id"
Fry's friends: Bender,Leela

