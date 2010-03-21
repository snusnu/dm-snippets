require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Task
  include DataMapper::Resource
  default_scope(:default).update(:order => [:prio.desc])
  property :id,   Serial
  property :prio, Integer
end

Task.auto_migrate!

Task.create :prio => 1
Task.create :prio => 2

Task.all.each do |p|
  puts p.inspect
end

__END__

ree-1.8.7-2010.01 mungo:snippets snusnu$ ruby default_scope.rb 
 ~ (0.000038) SELECT sqlite_version(*)
 ~ (0.000057) DROP TABLE IF EXISTS "tasks"
 ~ (0.000011) PRAGMA table_info("tasks")
 ~ (0.000247) CREATE TABLE "tasks" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "prio" INTEGER)
 ~ (0.000039) INSERT INTO "tasks" ("prio") VALUES (1)
 ~ (0.000031) INSERT INTO "tasks" ("prio") VALUES (2)
 ~ (0.000028) SELECT "id", "prio" FROM "tasks" ORDER BY "prio" DESC
#<Task @id=2 @prio=2>
#<Task @id=1 @prio=1>
