require 'rubygems'
require 'dm-core'
require 'dm-constraints'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'mysql://localhost/dm-constraints_test')

class Post
  include DataMapper::Resource
  property :id, Serial
end

class Tag
  include DataMapper::Resource
  property :id, Serial
end

class PostTag

  include DataMapper::Resource

  property :post_id, Integer, :key => true
  property :tag_id,  Integer, :key => true

  belongs_to :post
  belongs_to :tag

end

DataMapper.auto_migrate!


# Here the problem (at least on mysql) is that the FK type and the PK type don't match "enough"

# CREATE TABLE "posts" ("id" INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ...)
# CREATE TABLE "post_tags" ("post_id" INTEGER NOT NULL ...)

# Additional information from mysql

# ------------------------
# LATEST FOREIGN KEY ERROR
# ------------------------
# 090823  8:37:54 Error in foreign key constraint of table alfred/#sql-183e_80:
#  FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION:
# Cannot find an index in the referenced table where the
# referenced columns appear as the first columns, or column types
# in the table and the referenced table do not match for constraint. <<--- THIS IS THE REASON FOR THE ERROR
# Note that the internal storage type of ENUM and SET changed in
# tables created with >= InnoDB-4.1.12, and such columns in old tables
# cannot be referenced by such columns in new tables.
# See http://dev.mysql.com/doc/refman/5.1/en/innodb-foreign-key-constraints.html
# for correct foreign key definition.


# /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints.rb:29: warning: already initialized constant OPTIONS
#  ~ (0.000088) SET sql_auto_is_null = 0
#  ~ (0.000092) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
#  ~ (0.000379) SHOW TABLES LIKE 'posts'
#  ~ (0.000244) SHOW TABLES LIKE 'tags'
#  ~ (0.000242) SHOW TABLES LIKE 'post_tags'
#  ~ (0.000282) SELECT COUNT(*) FROM "information_schema"."table_constraints" WHERE "constraint_type" = 'FOREIGN KEY' AND "table_schema" = 'dm-constraints_test' AND "table_name" = 'post_tags' AND "constraint_name" = 'post_tags_post_fk'
#  ~ (0.000206) SELECT COUNT(*) FROM "information_schema"."table_constraints" WHERE "constraint_type" = 'FOREIGN KEY' AND "table_schema" = 'dm-constraints_test' AND "table_name" = 'post_tags' AND "constraint_name" = 'post_tags_tag_fk'
#  ~ (0.002062) DROP TABLE IF EXISTS "posts"
#  ~ (0.090646) DROP TABLE IF EXISTS "tags"
#  ~ (0.001772) DROP TABLE IF EXISTS "post_tags"
#  ~ (0.000450) SHOW TABLES LIKE 'posts'
#  ~ (0.000933) SHOW VARIABLES LIKE 'character_set_connection'
#  ~ (0.000778) SHOW VARIABLES LIKE 'collation_connection'
#  ~ (0.101760) CREATE TABLE "posts" ("id" INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY("id")) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
#  ~ (0.000491) SHOW TABLES LIKE 'tags'
#  ~ (0.240051) CREATE TABLE "tags" ("id" INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY("id")) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
#  ~ (0.000419) SHOW TABLES LIKE 'post_tags'
#  ~ (0.142479) CREATE TABLE "post_tags" ("post_id" INTEGER NOT NULL, "tag_id" INTEGER NOT NULL, PRIMARY KEY("post_id", "tag_id")) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
#  ~ (0.000737) SELECT COUNT(*) FROM "information_schema"."table_constraints" WHERE "constraint_type" = 'FOREIGN KEY' AND "table_schema" = 'dm-constraints_test' AND "table_name" = 'post_tags' AND "constraint_name" = 'post_tags_post_fk'
#  ~ Can't create table 'dm-constraints_test.#sql-183e_85' (errno: 150) (code: 1005, sql state: HY000, query: ALTER TABLE "post_tags" ADD CONSTRAINT "post_tags_post_fk" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, uri: mysql://localhost/dm-constraints_test)
# /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/adapters/data_objects_adapter.rb:163:in `execute_non_query': Can't create table 'dm-constraints_test.#sql-183e_85' (errno: 150) (DataObjects::SQLError)
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/adapters/data_objects_adapter.rb:163:in `execute'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/adapters/data_objects_adapter.rb:267:in `with_connection'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/adapters/data_objects_adapter.rb:161:in `execute'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:86:in `create_relationship_constraint'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:268:in `send'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:268:in `execute_each_relationship'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:267:in `each_value'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:267:in `execute_each_relationship'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:258:in `auto_migrate_up_with_constraints!'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/migrations.rb:51:in `send'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/migrations.rb:51:in `repository_execute'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model/descendant_set.rb:35:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model/descendant_set.rb:35:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/migrations.rb:50:in `repository_execute'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-constraints-0.10.0/lib/dm-constraints/migrations.rb:23:in `auto_migrate_up!'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/migrations.rb:24:in `auto_migrate!'
#   from new_ticket.rb:30

