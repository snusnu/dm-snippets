require 'rubygems'
require 'dm-core'
 
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root@localhost/rails3_development")
 
class Project
    include ::DataMapper::Resource
 
    property :id, Serial
    property :title, String
    property :user_id, Integer
 
    has n,     :tasks
    belongs_to :user
end
 
class User
    include ::DataMapper::Resource
    
    property :id, Serial
    property :fname, String
    property :lname, String
 
    has n, :tasks
    has n, :answers
end
 
class Task
    include ::DataMapper::Resource
    
    property :id, Serial
    property :project_id, Integer
    property :user_id, Integer
    
    belongs_to :project
    belongs_to :user
end
 
class Answer
    include ::DataMapper::Resource
 
    property :task_id, Integer
    property :user_id, Integer
    
    belongs_to :task
    belongs_to :user
end
 
::DataMapper.auto_migrate!
 
Task.all('project.title' => 'title', 'user.fname' => 'name').to_a
 
debugger; 1
