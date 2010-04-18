require "rubygems"
require "dm-core"
require "dm-migrations"

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Camera
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  has n, :fields, 'CameraProperty'
  has n, :lens
end

class CameraProperty
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  belongs_to :camera
end

class Len
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  belongs_to :camera
  has n, :fields, 'LenProperty'
end

class LenProperty
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  belongs_to :len
end

DataMapper.auto_migrate!

c = Camera.new(:name => 'Model A')
c.fields.new(:name => 'Height')
c.fields.new(:name => 'Width')
c.save

l = Len.new(:name => '35mm')
l.camera = Camera.get(1)
l.fields.new(:name => 'focal')
l.save

puts Camera.get(1).fields.all.length
puts Len.get(1).fields.all.length
puts Camera.get(1).lens.first.fields.length

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby 1208.rb 
 ~ (0.000044) SELECT sqlite_version(*)
 ~ (0.000058) DROP TABLE IF EXISTS "cameras"
 ~ (0.000009) PRAGMA table_info("cameras")
 ~ (0.000261) CREATE TABLE "cameras" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50))
 ~ (0.000011) DROP TABLE IF EXISTS "camera_properties"
 ~ (0.000007) PRAGMA table_info("camera_properties")
 ~ (0.000108) CREATE TABLE "camera_properties" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "camera_id" INTEGER NOT NULL)
 ~ (0.000092) CREATE INDEX "index_camera_properties_camera" ON "camera_properties" ("camera_id")
 ~ (0.000013) DROP TABLE IF EXISTS "lens"
 ~ (0.000007) PRAGMA table_info("lens")
 ~ (0.000119) CREATE TABLE "lens" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "camera_id" INTEGER NOT NULL)
 ~ (0.000087) CREATE INDEX "index_lens_camera" ON "lens" ("camera_id")
 ~ (0.000010) DROP TABLE IF EXISTS "len_properties"
 ~ (0.000013) PRAGMA table_info("len_properties")
 ~ (0.000108) CREATE TABLE "len_properties" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50), "len_id" INTEGER NOT NULL)
 ~ (0.000079) CREATE INDEX "index_len_properties_len" ON "len_properties" ("len_id")
 ~ (0.000045) INSERT INTO "cameras" ("name") VALUES ('Model A')
 ~ (0.000048) INSERT INTO "camera_properties" ("name", "camera_id") VALUES ('Height', 1)
 ~ (0.000049) INSERT INTO "camera_properties" ("name", "camera_id") VALUES ('Width', 1)
 ~ (0.000035) SELECT "id", "name" FROM "cameras" WHERE "id" = 1 ORDER BY "id" LIMIT 1
/Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource.rb:639:in `collection': stack level too deep (SystemStackError)
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/associations/one_to_many.rb:94:in `lazy_load'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource/state/persisted.rb:23:in `lazy_load'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource/state/persisted.rb:8:in `get'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/model/relationship.rb:344:in `fields'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource.rb:675:in `query'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource.rb:665:in `collection_for_self'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource.rb:640:in `collection'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/associations/one_to_many.rb:94:in `lazy_load'
	 ... 7847 levels...
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource/state.rb:13:in `get'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/resource/state/transient.rb:9:in `get'
	from /Users/snusnu/.rvm/gems/ree-1.8.7-2010.01/bundler/gems/dm-core-37b4bd22b9e3842977cf83d32baba459607e900a-master/lib/dm-core/model/relationship.rb:365:in `camera='
	from 1208.rb:54
