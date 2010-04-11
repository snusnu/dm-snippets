require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory')

class Activity
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
  has n, :activity_fields
  after :save do
    self.activity_fields.create :name => 'default field'
  end
end

class ActivityField
  include DataMapper::Resource
  property :id,          Serial
  property :name,        String
  property :activity_id, Integer
  belongs_to :activity
end


DataMapper.auto_migrate!

Activity.create :name => 'AAA'

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby 1235.rb 
 ~ (0.000045) SELECT sqlite_version(*)
 ~ (0.045876) DROP TABLE IF EXISTS "activities"
 ~ (0.000021) PRAGMA table_info("activities")
 ~ (0.002323) CREATE TABLE "activities" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
 ~ (0.002498) DROP TABLE IF EXISTS "activity_fields"
 ~ (0.000021) PRAGMA table_info("activity_fields")
 ~ (0.002648) CREATE TABLE "activity_fields" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "activity_id" INTEGER)
 ~ (0.003030) INSERT INTO "activities" ("name") VALUES ('AAA')
 ~ (0.001995) INSERT INTO "activity_fields" ("name", "activity_id") VALUES ('default field', 1)
