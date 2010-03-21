require "rubygems"
require "dm-core"

log = DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, 'sqlite3::memory:')

class Article
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    has n, :posts
end

class Post
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    belongs_to :article, :nullable => true
end

DataMapper.auto_migrate!

Post.new(:title => "Ghost Post").save

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby mykhal.rb 
 ~ (0.000043) SELECT sqlite_version(*)
 ~ (0.000075) DROP TABLE IF EXISTS "articles"
 ~ (0.000021) DROP TABLE IF EXISTS "posts"
 ~ (0.000012) PRAGMA table_info("articles")
 ~ (0.000337) CREATE TABLE "articles" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" VARCHAR(50))
 ~ (0.000012) PRAGMA table_info("posts")
 ~ (0.000166) CREATE TABLE "posts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" VARCHAR(50), "article_id" INTEGER)
 ~ (0.000203) CREATE INDEX "index_posts_article" ON "posts" ("article_id")
 ~ (0.000071) INSERT INTO "posts" ("title") VALUES ('Ghost Post')
