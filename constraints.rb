require "rubygems"
require "dm-core"
require "dm-constraints"
require "dm-validations"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'mysql://localhost/dm-playground')

class Person
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations

  has n, :project_memberships,
    :constraint => :destroy

  has n, :projects,
    :through => :project_memberships
  
end

class Project
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations

  has n, :project_memberships,
    :constraint => :destroy

  has n, :people,
    :through => :project_memberships

end

class ProjectMembership
  
  include DataMapper::Resource
  
  # properties
  
  property :id,         Serial
  property :person_id,  Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  
  # associations
  
  belongs_to :person
  belongs_to :project
  
end


describe "destroying a scoped many_to_many target collection" do
  
  before(:all) do
    DataMapper.auto_migrate!
  end
  
  it "should destroy the right intermediaries and the target resource(s)" do
    
    person               = Person.create(:name => 'snsunu')
    project_1            = Project.create(:name => 'dm-accepts_nested_attributes')
    project_2            = Project.create(:name => 'dm-is-localizable')
    project_membership_1 = ProjectMembership.create(:person => person, :project => project_1)
    project_membership_2 = ProjectMembership.create(:person => person, :project => project_2)
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 2
    Project.all.size.should           == 2

    m2m_relationship = person.class.relationships[:projects]
    
    target_query      = { m2m_relationship.child_key.first.name => project_1.key }
    target_collection = m2m_relationship.get(person, target_query)
    
    target_collection.size.should == 1
    target_collection.should include(project_1)
    
    target_collection.destroy
    
    lambda { person.save }.should_not raise_error
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should           == 1
    
  end
  
end