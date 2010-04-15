require 'dm-core'
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, "sqlite3::memory")

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.logger.debug( "Starting Migration" )

migration 1, :create_people_table do
  up do
    create_table :people do
      column :id,   Integer, :serial => true
      column :name, String, :size => 50
      column :age,  Integer
      column :foo,  DataMapper::Types::Text
    end
  end
  down do
    drop_table :people
  end
end

if $0 == __FILE__
  if $*.first == "down"
    migrate_down!
  else
    migrate_up!
  end
end

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby 1181.rb 
 ~ Starting Migration
 == Performing Up Migration #1: create_people_table
   CREATE TABLE "people" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "age" INTEGER, "foo" VARCHAR(65535))
   -> 0.1039s
 -> 0.1045s
