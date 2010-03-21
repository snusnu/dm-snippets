require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Project
  include DataMapper::Resource
  property :id, Serial
end
DataMapper.auto_upgrade!

class Task
  include DataMapper::Resource
  property :id, Serial
end
DataMapper.auto_upgrade!

class Task
  belongs_to :project #, :nullable => true
end
DataMapper.auto_upgrade!

__END__

mungo:snippets snusnu$ ruby oranj.rb 
 ~ (0.000185) PRAGMA table_info("projects")
 ~ (0.000064) SELECT sqlite_version(*)
 ~ (0.000371) CREATE TABLE "projects" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000013) PRAGMA table_info("projects")
 ~ (0.000010) PRAGMA table_info("projects")
 ~ (0.000017) PRAGMA table_info("tasks")
 ~ (0.000127) CREATE TABLE "tasks" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000011) PRAGMA table_info("projects")
 ~ (0.000010) PRAGMA table_info("projects")
 ~ (0.000011) PRAGMA table_info("tasks")
 ~ (0.000010) PRAGMA table_info("tasks")

alfredbutler: tip[pastie auto_upgrade!] Currently, if you add a belongs_to relationship in a reopened class, <code>DataMapper.auto_upgrade!</code> won't catch the implicitly added FK property. Have a look at this [pastie](http://pastie.org/627517) for a demonstration