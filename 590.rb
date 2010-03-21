require "rubygems"
require "dm-core"
require "dm-types"
require "dm-aggregates"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

module DataMapper
  # this is a dummy type which does nothing
  module Types
    class ZooName < DataMapper::Type
      primitive String
      size 128

      def self.load(value, property)
        value
      end

      def self.dump(value, property)
        value.is_a?(Array) ? raise("OMG IT'S AN ARRAY!") : value
      end

      def self.typecast(value, property)
        value
      end
    end
  end
end

class Zoo
  include DataMapper::Resource

  property :id,   Integer, :key => true
  property :name, ZooName, :key => true
  
  has 1, :marty, 'Animal'
end

class Animal
  include DataMapper::Resource

  property :id,       Serial
  property :zoo_id,   Integer
  property :zoo_name, ZooName
  property :name,     String
  
  belongs_to :zoo
end

describe "When using composite keys, the dump method in a custom type" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should not receive value as an Array" do
    zoo = Zoo.create(:id => 1, :name => 'Madagascar')
    lambda {
      zoo.marty = Animal.create(:zoo => zoo, :name => 'Marty')
    }.should_not raise_error
  end
end

# mungo:snippets snusnu$ spec -cfs 590.rb 
# 
# When using composite keys, the dump method in a custom type
#  ~ (0.000683) SELECT sqlite_version(*)
#  ~ (0.000116) DROP TABLE IF EXISTS "zoos"
#  ~ (0.000015) DROP TABLE IF EXISTS "animals"
#  ~ (0.000024) PRAGMA table_info("zoos")
#  ~ (0.000351) CREATE TABLE "zoos" ("id" INTEGER NOT NULL, "name" VARCHAR(50) NOT NULL, PRIMARY KEY("id", "name"))
#  ~ (0.000009) PRAGMA table_info("animals")
#  ~ (0.000205) CREATE TABLE "animals" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "zoo_id" INTEGER, "zoo_name" VARCHAR(50), "name" VARCHAR(50))
#  ~ (0.000069) INSERT INTO "zoos" ("id", "name") VALUES (1, 'Madagascar')
#  ~ (0.000049) INSERT INTO "animals" ("zoo_id", "zoo_name", "name") VALUES (1, 'Madagascar', 'Marty')
#  ~ (0.000055) SELECT "id", "zoo_id", "zoo_name", "name" FROM "animals" WHERE "zoo_id" = 1 AND "zoo_name" = 'Madagascar' ORDER BY "id"
# - should not receive value as an Array
# 
# Finished in 0.010488 seconds
# 
# 1 example, 0 failures
