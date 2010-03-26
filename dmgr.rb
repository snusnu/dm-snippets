#!/usr/bin/env ruby
#
# A one file test to show ...
require 'dm-core'


# setup the logger
DataMapper::Logger.new(STDOUT, :debug)

# connect to the DB
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource

  # properties
  property :id, Serial
  def self.auto_migrate!
    puts "XXXXXXXX"
    super
  end
end

Person.auto_migrate!

# put the code here!


__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby dmgr.rb 
XXXXXXXX
 ~ (0.000041) SELECT sqlite_version(*)
 ~ (0.000063) DROP TABLE IF EXISTS "people"
 ~ (0.000016) PRAGMA table_info("people")
 ~ (0.000259) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ 


