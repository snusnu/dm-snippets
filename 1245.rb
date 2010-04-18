#!/usr/bin/env ruby

require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
  timestamps :at
end

class Robot
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
  timestamps :on
end

DataMapper.auto_migrate!

p = Person.create(:name => 'fry', :created_at => DateTime.now-1, :updated_at => DateTime.now-1)
puts p.created_at.to_s # set to yesterday
puts p.updated_at.to_s # not set to yesterday

t = Robot.create(:name => 'bender', :created_on => Date.today-1, :updated_on => Date.today-1)
puts t.created_on.to_s # set to yesterday
puts t.updated_on.to_s # not set to yesterday

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby 1245.rb 
 ~ (0.000037) SELECT sqlite_version(*)
 ~ (0.000068) DROP TABLE IF EXISTS "people"
 ~ (0.000010) PRAGMA table_info("people")
 ~ (0.000262) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "created_at" TIMESTAMP NOT NULL, "updated_at" TIMESTAMP NOT NULL)
 ~ (0.000018) DROP TABLE IF EXISTS "robots"
 ~ (0.000007) PRAGMA table_info("robots")
 ~ (0.000124) CREATE TABLE "robots" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "created_on" DATE NOT NULL, "updated_on" DATE NOT NULL)
 ~ (0.000054) INSERT INTO "people" ("name", "created_at", "updated_at") VALUES ('fry', '2010-04-17T18:24:09+02:00', '2010-04-18T18:24:09+02:00')
2010-04-17T18:24:09+02:00
2010-04-18T18:24:09+02:00
 ~ (0.000048) INSERT INTO "robots" ("name", "created_on", "updated_on") VALUES ('bender', '2010-04-17', '2010-04-18')
2010-04-17
2010-04-18


