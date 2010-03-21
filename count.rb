require 'rubygems'
require 'dm-core'
require 'dm-aggregates'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

class Model
  include DataMapper::Resource 
  property :id, Serial
  def self.count(*args)
    puts "before count"
    result = super(*args)
    puts "after count"
    result
  end
end

DataMapper.auto_migrate!

puts Model.count

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby count.rb 
 ~ (0.000038) SELECT sqlite_version(*)
 ~ (0.174842) DROP TABLE IF EXISTS "models"
 ~ (0.000034) PRAGMA table_info("models")
 ~ (0.003612) CREATE TABLE "models" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
before count
 ~ (0.000043) SELECT COUNT(*) FROM "models"
after count
0
