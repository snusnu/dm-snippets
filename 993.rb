require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Child
  include DataMapper::Resource

  property :integer_key, Integer, :key => true
  property :boolean_key, Boolean, :key => true

  belongs_to :parent, :child_key => [:integer_key, :boolean_key]
end

class Parent
  include DataMapper::Resource

  property :integer_key, Integer, :key => true
  property :boolean_key, Boolean, :key => true
  
  property :desc, String

  has n, :children, :child_key => [:integer_key, :boolean_key]
end

DataMapper.auto_migrate!

puts '-'*80

parent1 = Parent.create(:integer_key => 1, :boolean_key => true,  :desc => 'dunno exactly')
parent2 = Parent.create(:integer_key => 1, :boolean_key => false, :desc => 'still dunno')

puts "parent1 = #{parent1.inspect}"
puts "parent2 = #{parent2.inspect}"

child1  = Child.create(:integer_key => parent1.integer_key, :boolean_key => true)
child2  = Child.create(:integer_key => parent1.integer_key, :boolean_key => false)

puts "child1 = #{child1.inspect}"
puts "child2 = #{child2.inspect}"

parent1.reload
parent2.reload
child1.reload
child2.reload

puts "child1.parent = #{child1.parent.inspect}"
puts "child2.parent = #{child2.parent.inspect}"


# WITHOUT the reloading this gives me

#  ~ (0.000130) SELECT sqlite_version(*)
#  ~ (0.000109) DROP TABLE IF EXISTS "children"
#  ~ (0.000024) DROP TABLE IF EXISTS "parents"
#  ~ (0.000022) PRAGMA table_info("children")
#  ~ (0.000336) CREATE TABLE "children" ("integer_key" INTEGER NOT NULL, "boolean_key" BOOLEAN NOT NULL, PRIMARY KEY("integer_key", "boolean_key"))
#  ~ (0.000008) PRAGMA table_info("parents")
#  ~ (0.000156) CREATE TABLE "parents" ("integer_key" INTEGER NOT NULL, "boolean_key" BOOLEAN NOT NULL, "desc" VARCHAR(50), PRIMARY KEY("integer_key", "boolean_key"))
# --------------------------------------------------------------------------------
#  ~ (0.000044) INSERT INTO "parents" ("integer_key", "boolean_key", "desc") VALUES (1, 't', 'dunno exactly')
#  ~ (0.000061) INSERT INTO "parents" ("integer_key", "boolean_key", "desc") VALUES (1, 'f', 'still dunno')
# parent1 = #<Parent @integer_key=1 @boolean_key=true @desc="dunno exactly">
# parent2 = #<Parent @integer_key=1 @boolean_key=false @desc="still dunno">
#  ~ (0.000040) INSERT INTO "children" ("integer_key", "boolean_key") VALUES (1, 't')
#  ~ (0.000048) INSERT INTO "children" ("integer_key", "boolean_key") VALUES (1, 'f')
# child1 = #<Child @integer_key=1 @boolean_key=true>
# child2 = #<Child @integer_key=1 @boolean_key=false>
#  ~ (0.000058) SELECT "integer_key", "boolean_key", "desc" FROM "parents" WHERE "integer_key" = 1 AND "boolean_key" = 't' ORDER BY "integer_key", "boolean_key" LIMIT 1
# child1.parent = #<Parent @integer_key=1 @boolean_key=true @desc="dunno exactly">
# child2.parent = nil


# WITH reloading this gives me

# mungo:snippets snusnu$ ruby 993.rb 
#  ~ (0.000139) SELECT sqlite_version(*)
#  ~ (0.000095) DROP TABLE IF EXISTS "children"
#  ~ (0.000024) DROP TABLE IF EXISTS "parents"
#  ~ (0.000024) PRAGMA table_info("children")
#  ~ (0.000339) CREATE TABLE "children" ("integer_key" INTEGER NOT NULL, "boolean_key" BOOLEAN NOT NULL, PRIMARY KEY("integer_key", "boolean_key"))
#  ~ (0.000010) PRAGMA table_info("parents")
#  ~ (0.000156) CREATE TABLE "parents" ("integer_key" INTEGER NOT NULL, "boolean_key" BOOLEAN NOT NULL, "desc" VARCHAR(50), PRIMARY KEY("integer_key", "boolean_key"))
# --------------------------------------------------------------------------------
#  ~ (0.000059) INSERT INTO "parents" ("integer_key", "boolean_key", "desc") VALUES (1, 't', 'dunno exactly')
#  ~ (0.000041) INSERT INTO "parents" ("integer_key", "boolean_key", "desc") VALUES (1, 'f', 'still dunno')
# parent1 = #<Parent @integer_key=1 @boolean_key=true @desc="dunno exactly">
# parent2 = #<Parent @integer_key=1 @boolean_key=false @desc="still dunno">
#  ~ (0.000039) INSERT INTO "children" ("integer_key", "boolean_key") VALUES (1, 't')
#  ~ (0.000039) INSERT INTO "children" ("integer_key", "boolean_key") VALUES (1, 'f')
# child1 = #<Child @integer_key=1 @boolean_key=true>
# child2 = #<Child @integer_key=1 @boolean_key=false>
#  ~ (0.000036) SELECT "integer_key", "boolean_key", "desc" FROM "parents" WHERE "boolean_key" = 't' AND "integer_key" = 1
# /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model/property.rb:187:in `zip': can't convert nil into Array (TypeError)
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model/property.rb:187:in `key_conditions'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:829:in `query'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:660:in `collection'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:817:in `reload_attributes'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:285:in `reload'
#   from 993.rb:44
