require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper.setup(:default, "sqlite3::memory:")

class Person
  include DataMapper::Resource
  property :id, Serial
  has 1, :profile
  has n, :project_memberships
  has n, :projects, :through => :project_memberships
end

class Profile
  include DataMapper::Resource
  property :id, Serial
  property :person_id, Integer, :nullable => false
  belongs_to :person
end

class Project
  include DataMapper::Resource
  property :id, Serial
  has n, :tasks
end

class ProjectMembership
  include DataMapper::Resource
  property :id, Serial
  property :person_id, Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  belongs_to :person
  belongs_to :project
end

class Task
  include DataMapper::Resource
  property :id, Serial
  property :project_id, Integer, :nullable => false
  belongs_to :project
end


describe "Resource#validatable?" do
  
  before(:all) do
    DataMapper.auto_migrate!
  end
  
  describe "when called directly on a Resource" do
    it "should return true if dm-validations are present" do
      Person.create.should be_validatable
      Profile.create.should be_validatable
      Project.create.should be_validatable
      ProjectMembership.create.should be_validatable
    end
  end
  
  describe "when called on an DataMapper::Associations::ManyToOne::Proxy" do
    
    it "should return true if dm-validations are present" do
      person  = Person.create
      project = Project.create
      membership = ProjectMembership.create :person => person, :project => project
      membership.person.should be_validatable
      membership.project.should be_validatable
    end
    
  end
  
  describe "when called on an DataMapper::Associations::OneToMany::Proxy" do
    
    describe "that points to a Resource related with has(n)" do
    
      it "should return true if dm-validations are present" do
        p = Project.create
        t = Task.create :project_id => p.id
        p.reload
        p.tasks.all? { |task| task.validatable? }.should be_true
      end
      
    end
    
    describe "that points to a Resource related with has(n, :through)" do
    
      it "should return true if dm-validations are present" do
        person  = Person.create
        project = Project.create
        membership = ProjectMembership.create :person => person, :project => project
        person.reload
        person.projects.all? { |p| p.validatable? }.should be_true
      end
      
    end
    
  end
  
end

# mungo:Desktop snusnu$ spec -c -f -s validatable.rb 
# 
# Resource#validatable? when called directly on a Resource
# - should return true if dm-validations are present
# 
# Resource#validatable? when called on an DataMapper::Associations::ManyToOne::Proxy
# - should return true if dm-validations are present (FAILED - 1)
# 
# Resource#validatable? when called on an DataMapper::Associations::OneToMany::Proxy that points to a Resource related with has(n)
# - should return true if dm-validations are present
# 
# Resource#validatable? when called on an DataMapper::Associations::OneToMany::Proxy that points to a Resource related with has(n, :through)
# - should return true if dm-validations are present
# 
# 1)
# 'Resource#validatable? when called on an DataMapper::Associations::ManyToOne::Proxy should return true if dm-validations are present' FAILED
# expected validatable? to return true, got false
# ./validatable.rb:67:
# 
# Finished in 0.028411 seconds
# 
# 4 examples, 1 failure