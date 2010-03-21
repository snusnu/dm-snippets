require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Post

  include DataMapper::Resource

  property :id, Serial

  has n, :post_tags, :constraint => :destroy # <-- COMMENT the :constraint => :destroy and everything works
  has n, :tags, :through => :post_tags

  def tag_list=(list)
    list.each do |tag|
      new_tag = Tag.first_or_create(:name => tag)
      tags << new_tag
    end
  end

end

class PostTag

  include DataMapper::Resource

  property :post_id, Integer, :key => true
  property :tag_id,  Integer, :key => true

  belongs_to :post
  belongs_to :tag

end

class Tag

  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :nullable => false, :unique => true, :unique_index => true

  property :created_at, DateTime

  has n, :post_tags

  has n, :posts,
    :through => :post_tags

end

DataMapper.auto_migrate!

Post.create(:tag_list => ['foo'])

# mungo:snippets snusnu$ ruby constraints-problem.rb 
#  ~ (0.000159) SELECT sqlite_version(*)
#  ~ (0.000112) DROP TABLE IF EXISTS "posts"
#  ~ (0.000022) DROP TABLE IF EXISTS "post_tags"
#  ~ (0.000016) DROP TABLE IF EXISTS "tags"
#  ~ (0.000027) PRAGMA table_info("posts")
#  ~ (0.000372) CREATE TABLE "posts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000019) PRAGMA table_info("post_tags")
#  ~ (0.000245) CREATE TABLE "post_tags" ("post_id" INTEGER NOT NULL, "tag_id" INTEGER NOT NULL, PRIMARY KEY("post_id", "tag_id"))
#  ~ (0.000014) PRAGMA table_info("tags")
#  ~ (0.000118) CREATE TABLE "tags" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50) NOT NULL, "created_at" TIMESTAMP)
#  ~ (0.000117) CREATE UNIQUE INDEX "unique_tags_name" ON "tags" ("name")
#  ~ (0.000033) SELECT "id", "name", "created_at" FROM "tags" WHERE "name" = 'foo'
#  ~ (0.000046) INSERT INTO "tags" ("name") VALUES ('foo')
# /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1050:in `append_condition':  is an invalid instance: NilClass (ArgumentError)
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1096:in `append_string_condition'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1046:in `append_condition'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1080:in `append_symbol_condition'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1045:in `append_condition'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1015:in `normalize_links'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1005:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:1005:in `normalize_links'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:682:in `initialize'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:354:in `update'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/relationship.rb:131:in `query_for'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/repository.rb:110:in `scope'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/relationship.rb:129:in `query_for'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:48:in `collection_for'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:144:in `lazy_load'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:67:in `get'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:112:in `tags'
#   from constraints-problem.rb:19:in `tag_list='
#   from constraints-problem.rb:17:in `each'
#   from constraints-problem.rb:17:in `tag_list='
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:266:in `send'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:266:in `attributes='
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:262:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:262:in `attributes='
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:738:in `initialize'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model.rb:412:in `new'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model.rb:412:in `new'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model.rb:643:in `_create'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model.rb:427:in `create'
#   from constraints-problem.rb:55