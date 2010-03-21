#!/usr/bin/env ruby
#
# A one file test to show ...
require 'rubygems'    
require 'dm-core'
require 'dm-types'
require 'dm-validations'


# setup the logger
DataMapper::Logger.new(STDOUT, :debug)

# connect to the DB
DataMapper.setup(:default, 'sqlite3::memory:')

class Feed
  include DataMapper::Resource

  property :id,           Serial

  property :title,        Text, :lazy => false
  property :url,          Text, :required => true, :lazy => false

  property :last_checked, DateTime
  property :status,       Enum[:unprocessed, :processed, :hidden]
  property :etag,         String

  property :created_at,   DateTime
  property :updated_at,   DateTime

  has n, :feed_subscriptions
  has n, :users, "User", :through => :feed_subscriptions

  validates_is_unique :url
end

class User

  include DataMapper::Resource

  property :id,          Serial

  has n, :subscriptions, 'FeedSubscription'
  has n, :feeds, :through => :subscriptions

end

class FeedSubscription
  include DataMapper::Resource

  property :feed_id, Integer, :required => true, :key => true, :min => 0
  property :user_id, Integer, :required => true, :key => true, :min => 0

  belongs_to :feed
  belongs_to :user
  
  validates_is_unique :feed_id, :scope => :user_id
end

DataMapper.auto_migrate!

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby advany.rb 
 ~ (0.000038) SELECT sqlite_version(*)
 ~ (0.000058) DROP TABLE IF EXISTS "feeds"
 ~ (0.000012) DROP TABLE IF EXISTS "users"
 ~ (0.000011) DROP TABLE IF EXISTS "feed_subscriptions"
 ~ (0.000010) PRAGMA table_info("feeds")
 ~ (0.000268) CREATE TABLE "feeds" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" TEXT, "url" TEXT NOT NULL, "last_checked" TIMESTAMP, "status" INTEGER, "etag" VARCHAR(50), "created_at" TIMESTAMP, "updated_at" TIMESTAMP)
 ~ (0.000022) PRAGMA table_info("users")
 ~ (0.000089) CREATE TABLE "users" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000007) PRAGMA table_info("feed_subscriptions")
 ~ (0.000137) CREATE TABLE "feed_subscriptions" ("feed_id" INTEGER NOT NULL, "user_id" INTEGER NOT NULL, PRIMARY KEY("feed_id", "user_id"))

