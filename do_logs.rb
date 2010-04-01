#!/usr/bin/env ruby
#
# A one file test to show ...
# $: << '../do/data_objects/lib'
# $: << 'lib'

require 'rubygems'
require 'data_objects'
require 'dm-core'
require 'do_postgres'

module CustomLog
  def log(message)
    puts "query    = #{message.query}"
    puts "start    = #{message.start}"
    puts "duration = #{message.duration}"
    super
  end
end

module DataObjects
  class Connection
    include CustomLog
  end
end

# setup the logger
DataMapper::Logger.new($stdout, :debug)

DataObjects::Postgres.logger = DataObjects::Logger.new($stdout, 0)

# connect to the DB
DataMapper.setup(:default, 'postgres://postgres@localhost/dm_core_test')

class Person
  include DataMapper::Resource

  # properties
  property :id,   Serial
  property :name, String, :required => true

end

DataMapper.auto_migrate!

puts '-'*80

Person.create :name => 'fry'
Person.create :name => 'leela'

Person.all.each { |p| puts "name = #{p.name}" }

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby do_logs.rb 
query    = SET backslash_quote = off
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 295
 ~ (0.000295) SET backslash_quote = off
query    = SET standard_conforming_strings = on
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 788
 ~ (0.000788) SET standard_conforming_strings = on
query    = SET client_min_messages = warning
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 175
 ~ (0.000175) SET client_min_messages = warning
query    = SELECT version()
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 593
 ~ (0.000593) SELECT version()
query    = SET client_min_messages = warning
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 128
 ~ (0.000128) SET client_min_messages = warning
query    = DROP TABLE IF EXISTS "people"
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 69545
 ~ (0.069545) DROP TABLE IF EXISTS "people"
query    = RESET client_min_messages
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 225
 ~ (0.000225) RESET client_min_messages
query    = SET client_min_messages = warning
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 129
 ~ (0.000129) SET client_min_messages = warning
query    = SELECT current_schema()
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 365
 ~ (0.000365) SELECT current_schema()
query    = SELECT COUNT(*) FROM "information_schema"."tables" WHERE "table_type" = 'BASE TABLE' AND "table_schema" = 'public' AND "table_name" = 'people'
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 3088
 ~ (0.003088) SELECT COUNT(*) FROM "information_schema"."tables" WHERE "table_type" = 'BASE TABLE' AND "table_schema" = 'public' AND "table_name" = 'people'
query    = CREATE TABLE "people" ("id" SERIAL NOT NULL, "name" VARCHAR(50) NOT NULL, PRIMARY KEY("id"))
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 5399
 ~ (0.005399) CREATE TABLE "people" ("id" SERIAL NOT NULL, "name" VARCHAR(50) NOT NULL, PRIMARY KEY("id"))
query    = RESET client_min_messages
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 328
 ~ (0.000328) RESET client_min_messages
--------------------------------------------------------------------------------
query    = INSERT INTO "people" ("name") VALUES ('fry') RETURNING "id"
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 2497
 ~ (0.002497) INSERT INTO "people" ("name") VALUES ('fry') RETURNING "id"
query    = INSERT INTO "people" ("name") VALUES ('leela') RETURNING "id"
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 2380
 ~ (0.002380) INSERT INTO "people" ("name") VALUES ('leela') RETURNING "id"
query    = SELECT "id", "name" FROM "people" ORDER BY "id"
start    = Thu Apr 01 22:27:49 +0200 2010
duration = 461
 ~ (0.000461) SELECT "id", "name" FROM "people" ORDER BY "id"
name = fry
name = leela
