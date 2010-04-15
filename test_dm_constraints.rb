#!/usr/bin/env ruby

require 'dm-core'
require 'dm-constraints'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/dm_core_test')

class Person
  include DataMapper::Resource
  property :id, Serial
  has n, :tasks, :constraint => :destroy
end

class Task
  include DataMapper::Resource
  property :id, Serial
  belongs_to :person
end

DataMapper.auto_migrate!


__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby test_dm_constraints.rb 
 ~ (0.000006) SET sql_auto_is_null = 0
 ~ (0.000003) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
 ~ (0.000002) DROP TABLE IF EXISTS `people`
 ~ (0.000005) SHOW TABLES LIKE 'people'
 ~ (0.000003) SET sql_auto_is_null = 0
 ~ (0.000003) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
 ~ (0.000002) SHOW VARIABLES LIKE 'character_set_connection'
 ~ (0.000005) SHOW VARIABLES LIKE 'collation_connection'
 ~ (0.000002) CREATE TABLE `people` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
 ~ (0.000003) DROP TABLE IF EXISTS `tasks`
 ~ (0.000006) SHOW TABLES LIKE 'tasks'
 ~ (0.000002) CREATE TABLE `tasks` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `person_id` INT(10) UNSIGNED NOT NULL, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
 ~ (0.000005) CREATE INDEX `index_tasks_person` ON `tasks` (`person_id`)

