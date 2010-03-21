# versions used:
# dm-core:
# commit f33ade77050440dcdd590a1ca7ef8709f1e0898d
# Author: Dirkjan Bussink <d.bussink@gmail.com>
# Date:   Wed Jun 10 16:36:53 2009 +0200
# 
# dm-more:
# commit 81116667834674db37c7874ee3a3576c7f989c2f
# Author: Dan Kubb <dan.kubb@gmail.com>
# Date:   Wed Jun 10 10:12:04 2009 -0700
# 
#     [dm-ar-finders] Moved find_by_sql into Model namespace
#     
#     * Minor refactoring of method_missing logic



require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"
 
DataMapper::Logger.new(STDOUT, :debug)

DataMapper.setup(:default, 'mysql://root:@localhost/test') 
 
class Project
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  
  # validates_present :name
end

DataMapper.auto_migrate!

p = Project.new(:name => "Oh yeah")
p.save
# => 
# dubbook:snippets michael$ ruby save_bug.rb 
#  ~ (0.000068) SET sql_auto_is_null = 0
#  ~ (0.000065) SET SESSION sql_mode = 'ANSI,NO_AUTO_VALUE_ON_ZERO,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
#  ~ (0.001885) DROP TABLE IF EXISTS "projects"
#  ~ (0.000270) SHOW TABLES LIKE 'projects'
#  ~ (0.000336) SHOW VARIABLES LIKE 'character_set_connection'
#  ~ (0.000305) SHOW VARIABLES LIKE 'collation_connection'
#  ~ (0.087183) CREATE TABLE "projects" ("id" INTEGER NOT NULL AUTO_INCREMENT, "name" VARCHAR(50), PRIMARY KEY("id")) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
# /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:64:in `save!': stack level too deep (SystemStackError)
#   from /Library/Ruby/Gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:356:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:56:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:64:in `save!'
#   from /Library/Ruby/Gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:356:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:56:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:64:in `save!'
#   from /Library/Ruby/Gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:356:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:56:in `save'
#    ... 4458 levels...
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:64:in `save!'
#   from /Library/Ruby/Gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:356:in `save'
#   from /Library/Ruby/Gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:56:in `save'
#   from save_bug.rb:21