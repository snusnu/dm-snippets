require "dm-core"
require 'dm-migrations'

require 'rubygems'
require 'ruby-debug'
Debugger.start

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "mysql://localhost/dm_core_test")

class Project
    include DataMapper::Resource

    property :id, Serial
    property :title, String

    has n, :tasks
end

class User
    include DataMapper::Resource
    
    property :id, Serial
    property :name, String

    has n, :tasks
end

class Task
    include DataMapper::Resource
    
    property :id, Serial

    property :project_id, Integer
    property :user_id, Integer
    
    belongs_to :project
    belongs_to :user
end

DataMapper.auto_migrate!

Task.all('project.title' => 'title', 'user.name' => 'name').to_a

debugger; 1

__END__
$ ruby foo.rb 
 ~ (0.000007) SET sql_auto_is_null = 0
 ~ (0.000002) SET SESSION sql_mode = 'ANSI,NO_BACKSLASH_ESCAPES,NO_DIR_IN_CREATE,NO_ENGINE_SUBSTITUTION,NO_UNSIGNED_SUBTRACTION,TRADITIONAL'
 ~ (0.000003) DROP TABLE IF EXISTS `projects`
 ~ (0.000003) DROP TABLE IF EXISTS `users`
 ~ (0.000002) DROP TABLE IF EXISTS `tasks`
 ~ (0.000002) SHOW TABLES LIKE 'projects'
 ~ (0.000003) SHOW VARIABLES LIKE 'character_set_connection'
 ~ (0.000002) SHOW VARIABLES LIKE 'collation_connection'
 ~ (0.000003) CREATE TABLE `projects` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `title` VARCHAR(50), PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
 ~ (0.000004) SHOW TABLES LIKE 'users'
 ~ (0.000002) CREATE TABLE `users` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `name` VARCHAR(50), PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
 ~ (0.000003) SHOW TABLES LIKE 'tasks'
 ~ (0.000002) CREATE TABLE `tasks` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, `project_id` INTEGER, `user_id` INTEGER, PRIMARY KEY(`id`)) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci
 ~ (0.000005) SELECT `tasks`.`id`, `tasks`.`project_id`, `tasks`.`user_id` FROM `tasks` INNER JOIN `users` ON `tasks`.`user_id` = `users`.`id` INNER JOIN `projects` ON `users`.`project_id` = `projects`.`id` WHERE (`users`.`name` = 'name' AND `projects`.`title` = 'title') GROUP BY `tasks`.`id`, `tasks`.`project_id`, `tasks`.`user_id` ORDER BY `tasks`.`id`
 ~ Unknown column 'users.project_id' in 'on clause' (code: 1054, sql state: 42S22, query: SELECT `tasks`.`id`, `tasks`.`project_id`, `tasks`.`user_id` FROM `tasks` INNER JOIN `users` ON `tasks`.`user_id` = `users`.`id` INNER JOIN `projects` ON `users`.`project_id` = `projects`.`id` WHERE (`users`.`name` = 'name' AND `projects`.`title` = 'title') GROUP BY `tasks`.`id`, `tasks`.`project_id`, `tasks`.`user_id` ORDER BY `tasks`.`id`, uri: mysql://root@localhost/foo)
/proj/work/dm-core.git/lib/dm-core/adapters/data_objects_adapter.rb:140:in `execute_reader': Unknown column 'users.project_id' in 'on clause' (DataObjects::SQLError)
	from /proj/work/dm-core.git/lib/dm-core/adapters/data_objects_adapter.rb:140:in `read'
	from /proj/work/dm-core.git/lib/dm-core/adapters/data_objects_adapter.rb:269:in `with_connection'
	from /proj/work/dm-core.git/lib/dm-core/adapters/data_objects_adapter.rb:136:in `read'
	from /proj/work/dm-core.git/lib/dm-core/repository.rb:145:in `read'
	from /proj/work/dm-core.git/lib/dm-core/collection.rb:1111:in `lazy_load'
	from /proj/work/extlib.git/lib/extlib/lazy_array.rb:275:in `to_a'
	from foo.rb:54
