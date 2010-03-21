require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper.setup(:default, "sqlite3::memory:")

module MarkForDestruction
  def mark_for_destruction
    @marked_for_destruction = true
  end
  def marked_for_destruction?
    @marked_for_destruction
  end
end

module Save
  def save(*args)
    if marked_for_destruction?
      destroy
    else
      super
    end
  end
end

class Person
  include DataMapper::Resource
  include MarkForDestruction
  include Save
  property :id, Serial
  has 1, :profile
end

class Profile
  include DataMapper::Resource
  include MarkForDestruction
  include Save
  property :id, Serial
  property :person_id, Integer, :nullable => false
  belongs_to :person
end

describe "Resource#save" do
  before(:each) do
    DataMapper.auto_migrate!
  end
  it "should save a newly associated resource" do
    p = Person.new
    p.profile = Profile.new
    p.save
    Person.all.size.should  == 1  
    Profile.all.size.should == 1  
  end
  it "should destroy a resource that is marked_for_destruction (FAILS)" do
    person  = Person.create
    person.profile = Profile.create :person => person
    person.profile.mark_for_destruction
    
    # FAILS 
    # because this is empty, dm never tries to call my
    # overwritten save, and thus never destroys the resource
    person.send(:child_associations).should_not be_empty
    
    person.save
    Person.all.size.should  == 1
    Profile.all.size.should == 0
  end
end


1) [DANA] Resource#mark_for_destruction object_id = 11014410, class = Profile, id = 3
2) [DANA] Resource#save class = Person, id = 3, object_id = 11014690
3) [dm-core] Resource#save: self.class = Person
4) [dm-core] Resource#save_children, collection = DataMapper::Associations::OneToMany::Collection
5) [dm-core] DataMapper::Associations::OneToMany::Collection#save: resource.object_id = 11014410, class = Profile
6) [dm-core] -- resource.marked_for_destruction? == true
7) [dm-core] -- about to call Resource#save
8) [dm-core] Resource#save: self.inspect = #, self.class = Profile
9) [dm-core] -- Resource#save returned true