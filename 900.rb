require "rubygems"
require "dm-core"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class User
  include DataMapper::Resource
  property :id, Serial
  has n, :recaps
end

class Recap
  include DataMapper::Resource
  property :id, Serial
  belongs_to :regatta
  belongs_to :author, User
end

class Regatta
  include DataMapper::Resource
  property :id, Serial
  has 1, :recap
end

describe "This setup" do

  before(:all) do
    DataMapper.auto_migrate!
  end

  it "should not recurse infinitely" do

    user    = User.create
    regatta = Regatta.create
    recap   = Recap.create :regatta => regatta, :author => user

    r = Recap.get(1)
    r.regatta.should == regatta

  end
end

# mungo:snippets snusnu$ spec -cfs markmt.rb 
# 
# This setup
#  ~ (0.000166) SELECT sqlite_version(*)
#  ~ (0.000108) DROP TABLE IF EXISTS "users"
#  ~ (0.000018) DROP TABLE IF EXISTS "recaps"
#  ~ (0.000026) DROP TABLE IF EXISTS "regattas"
#  ~ (0.000023) PRAGMA table_info("users")
#  ~ (0.000361) CREATE TABLE "users" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000017) PRAGMA table_info("recaps")
#  ~ (0.000121) CREATE TABLE "recaps" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "author_id" INTEGER NOT NULL, "regatta_id" INTEGER NOT NULL)
#  ~ (0.000131) CREATE INDEX "index_recaps_regatta" ON "recaps" ("regatta_id")
#  ~ (0.000101) CREATE INDEX "index_recaps_author" ON "recaps" ("author_id")
#  ~ (0.000009) PRAGMA table_info("regattas")
#  ~ (0.000111) CREATE TABLE "regattas" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000045) INSERT INTO "users" DEFAULT VALUES
#  ~ (0.000033) INSERT INTO "regattas" DEFAULT VALUES
#  ~ (0.000054) INSERT INTO "recaps" ("author_id", "regatta_id") VALUES (1, 1)
#  ~ (0.000028) SELECT "id", "author_id", "regatta_id" FROM "recaps" WHERE "id" = 1
#  ~ (0.000038) SELECT "id" FROM "regattas" WHERE "id" = 1 ORDER BY "id" LIMIT 1
# - should not recurse infinitely
# 
# Finished in 0.012402 seconds
# 
# 1 example, 0 failures
