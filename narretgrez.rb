require "rubygems"
require "dm-core"
require "dm-validations"
require "dm-is-remixable"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

module Metadata
  include DataMapper::Resource
  
  property :id,            Serial
  
  is :remixable
end

class Stamp
  include DataMapper::Resource
  
  property :id,       Serial
  
  remix n, :metadata
  
  enhance :metadata do
    belongs_to :datatype
  end  
end

class Content
  include DataMapper::Resource
  
  property :id,             Serial

  remix n,    :metadata
  
  enhance :metadata do
    belongs_to :datatype
  end
end

class Datatype
  include DataMapper::Resource
  
  property :id,            Serial
  property :name,          String
  
  has n, :content_metadata, "ContentMetadata"
  has n, :stamp_metadata, "StampMetadata"
end

puts DataMapper.auto_migrate!.inspect

s = Stamp.create
t = Datatype.create :name => 'foo'

puts s.stamp_metadatum


# mungo:snippets snusnu$ ruby narretgrez.rb 
#  ~ Generating Remixed Model: StampMetadata
#  ~ Generating Remixed Model: ContentMetadata
#  ~ Skipping auto_migrate_down! for remixable module (Metadata)
#  ~ (0.000135) SELECT sqlite_version(*)
#  ~ (0.000096) DROP TABLE IF EXISTS "stamps"
#  ~ (0.000019) DROP TABLE IF EXISTS "stamp_metadatum"
#  ~ (0.000016) DROP TABLE IF EXISTS "contents"
#  ~ (0.000048) DROP TABLE IF EXISTS "content_metadatum"
#  ~ (0.000016) DROP TABLE IF EXISTS "datatypes"
#  ~ Skipping auto_migrate_up! for remixable module (Metadata)
#  ~ (0.000024) PRAGMA table_info("stamps")
#  ~ (0.000361) CREATE TABLE "stamps" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000010) PRAGMA table_info("stamp_metadatum")
#  ~ (0.000116) CREATE TABLE "stamp_metadatum" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "stamp_id" INTEGER NOT NULL, "datatype_id" INTEGER NOT NULL)
#  ~ (0.000118) CREATE INDEX "index_stamp_metadatum_datatype" ON "stamp_metadatum" ("datatype_id")
#  ~ (0.000009) PRAGMA table_info("contents")
#  ~ (0.000105) CREATE TABLE "contents" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000009) PRAGMA table_info("content_metadatum")
#  ~ (0.000117) CREATE TABLE "content_metadatum" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "content_id" INTEGER NOT NULL, "datatype_id" INTEGER NOT NULL)
#  ~ (0.000111) CREATE INDEX "index_content_metadatum_datatype" ON "content_metadatum" ("datatype_id")
#  ~ (0.000008) PRAGMA table_info("datatypes")
#  ~ (0.000123) CREATE TABLE "datatypes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
# #<DataMapper::Model::DescendantSet:0x32bae0 @descendants=[Metadata, Stamp, StampMetadata, Content, ContentMetadata, Datatype], @ancestors=nil>
#  ~ (0.000036) INSERT INTO "datatypes" ("name") VALUES ('foo')

