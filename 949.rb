require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class User
  include DataMapper::Resource
  property :id, Serial
  has (0..1), :post
end

class Post
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
end

describe "User.has(0..1, :post) without explicit property definition at the target end" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should allow to save a user with an associated post" do
    p = Post.new
    p.user
    p.valid?
    p.errors
  end
end

# mungo:snippets snusnu$ spec -cfs 949.rb 
# 
# User.has(0..1, :post) without explicit property definition at the target end
#  ~ (0.000180) SELECT sqlite_version(*)
#  ~ (0.000104) DROP TABLE IF EXISTS "users"
#  ~ (0.000016) DROP TABLE IF EXISTS "posts"
#  ~ (0.000024) PRAGMA table_info("users")
#  ~ (0.000450) CREATE TABLE "users" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000009) PRAGMA table_info("posts")
#  ~ (0.000126) CREATE TABLE "posts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "user_id" INTEGER NOT NULL)
#  ~ (0.000122) CREATE INDEX "index_posts_user" ON "posts" ("user_id")
#  ~ (0.000047) INSERT INTO "users" DEFAULT VALUES
#  ~ (0.000045) INSERT INTO "posts" ("user_id") VALUES (1)
#  ~ (0.000073) SELECT "id" FROM "users" ORDER BY "id"
#  ~ (0.000025) SELECT "id", "user_id" FROM "posts" ORDER BY "id"
# - should allow to save a user with an associated post
# 
# Finished in 0.033208 seconds
# 
# 1 example, 0 failures

