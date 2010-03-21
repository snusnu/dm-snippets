require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Foo
  include DataMapper::Resource
  property :id, Serial
  has n, :bars
end

class Bar
  include DataMapper::Resource
  property :id, Serial
  property :value, Integer
  belongs_to :foo
end

DataMapper.auto_migrate!

Foo.create.tap {|foo|
  foo.bars.create(:value => 1)
  foo.bars.create(:value => 1)
}
Foo.create.tap {|foo|
  foo.bars.create(:value => 1)
}

foos = Foo.all
foos.inspect # ???
p foos[1].bars.first(:value => 1)
p foos[1]

foos = Foo.all
p foos[1].bars.first(:value => 1)
p foos[1]


# mungo:snippets snusnu$ ruby 1021.rb 
#  ~ (0.000235) SELECT sqlite_version(*)
#  ~ (0.000155) DROP TABLE IF EXISTS "foos"
#  ~ (0.000022) DROP TABLE IF EXISTS "bars"
#  ~ (0.000036) PRAGMA table_info("foos")
#  ~ (0.000554) CREATE TABLE "foos" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000014) PRAGMA table_info("bars")
#  ~ (0.000209) CREATE TABLE "bars" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "value" INTEGER, "foo_id" INTEGER NOT NULL)
#  ~ (0.000214) CREATE INDEX "index_bars_foo" ON "bars" ("foo_id")
#  ~ (0.000052) INSERT INTO "foos" DEFAULT VALUES
#  ~ (0.000088) INSERT INTO "bars" ("value", "foo_id") VALUES (1, 1)
#  ~ (0.000088) INSERT INTO "bars" ("value", "foo_id") VALUES (1, 1)
#  ~ (0.000053) INSERT INTO "foos" DEFAULT VALUES
#  ~ (0.000098) INSERT INTO "bars" ("value", "foo_id") VALUES (1, 2)
#  ~ (0.000052) SELECT "id" FROM "foos" ORDER BY "id"
#  ~ (0.000044) SELECT "id", "value", "foo_id" FROM "bars" WHERE "value" = 1 AND "foo_id" = 2 ORDER BY "id" LIMIT 1
# #<Bar @id=3 @value=1 @foo_id=2>
# #<Foo @id=2>
#  ~ (0.000023) SELECT "id" FROM "foos" ORDER BY "id" LIMIT 1 OFFSET 1
#  ~ (0.000036) SELECT "id", "value", "foo_id" FROM "bars" WHERE "value" = 1 AND "foo_id" = 2 ORDER BY "id" LIMIT 1
# #<Bar @id=3 @value=1 @foo_id=2>
#  ~ (0.000023) SELECT "id" FROM "foos" ORDER BY "id" LIMIT 1 OFFSET 1
# #<Foo @id=2>
