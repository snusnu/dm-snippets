require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Account
  include DataMapper::Resource
  property :id, Serial
  property :name, String
end

class User
  include DataMapper::Resource
  property :id, Serial
  belongs_to :account
end

describe "saving m:1 relationships" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should save a valid parent" do
    a = Account.new(:name => "foo")
    u = User.new
    u.account = a
    a.save.should be_true
    u.save.should be_true
    
    Account.all.size.should == 1
    Account.get(a.id).name.should == 'foo'
    User.all.size.should == 1
  end
end

# mungo:snippets snusnu$ spec -cfs 619.rb 
# 
# saving m:1 relationships
#  ~ (0.000143) SELECT sqlite_version(*)
#  ~ (0.000110) DROP TABLE IF EXISTS "accounts"
#  ~ (0.000026) DROP TABLE IF EXISTS "users"
#  ~ (0.000023) PRAGMA table_info("accounts")
#  ~ (0.000360) CREATE TABLE "accounts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
#  ~ (0.000017) PRAGMA table_info("users")
#  ~ (0.000113) CREATE TABLE "users" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "account_id" INTEGER NOT NULL)
#  ~ (0.000167) CREATE INDEX "index_users_account" ON "users" ("account_id")
#  ~ (0.000037) INSERT INTO "accounts" ("name") VALUES ('foo')
#  ~ (0.000057) INSERT INTO "users" ("account_id") VALUES (1)
#  ~ (0.000037) SELECT "id", "name" FROM "accounts" ORDER BY "id"
#  ~ (0.000024) SELECT "id", "name" FROM "accounts" WHERE "id" = 1
#  ~ (0.000022) SELECT "id", "account_id" FROM "users" ORDER BY "id"
# - should save a valid parent
# 
# Finished in 0.010888 seconds
# 
# 1 example, 0 failures
