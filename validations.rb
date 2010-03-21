require 'rubygems'
require 'spec'
require 'dm-core'
require 'dm-validations'
DataMapper.setup(:default, 'sqlite3::memory:')

class Person
  include DataMapper::Resource
  property :id,   Serial
  property :name, String, :nullable => false
  has 1, :profile
end

class Profile
  include DataMapper::Resource
  property :id,        Serial
  property :person_id, Integer, :nullable => false
  property :nick,      String,  :nullable => false
  belongs_to :person
end

DataMapper.auto_migrate!

describe "a valid resource associated via has(1)" do
  
  it "should be valid before the parent resource is saved" do
    p = Person.create :name => 'Martin'
    p.should be_valid
    p.profile = Profile.new :nick => 'snusnu'
    p.profile.should be_valid
    p.profile.save.should be_true
    p.save.should be_true
    Person.all.size.should == 1
    Profile.all.size.should == 1
  end
  
end






module AssociationValidation
  
  extend DataMapper::Chainable
  
  chainable do
    def save(context = :default)
      return false unless save_parent_associations(context)
      return false unless save_self(context)
      save_child_associations(context)
    end
  end

  private

  def save_parent_associations(context)
    parent_associations.all? do |a|
      before_save_parent_association(a, context)
      ret = a.save
      puts "save_parent_associations: save returned #{ret.inspect}, saved object = #{a.inspect}"
      ret
    end
  end

  def save_self(context)
    if context.nil?
      new? ? _create : _update
    else
      if valid?(context)
        new? ? _create : _update
      else
        puts "save FAIL: save_self failed with errors = #{self.errors.inspect}" 
        false
      end
    end
  end

  def save_child_associations(context)
    child_associations.all? do |a|
      before_save_child_association(a, context)
      ret = a.save
      puts "save_child_associations: save returned #{ret.inspect}, saved object = #{a.inspect}"
      ret
    end
  end

end


module TopDownWalk
  
  extend DataMapper::Chainable
  
  chainable do
    def save
      # save all the paths to self first, in order to 
      # avoid saving child associations more than once
      roots.each { |r| r.save_child_associations(self) }
      # now save all child associations
      save_child_associations
    end
  end
  
  def roots
    
  end
  
  # # recursively save all child associations
  # # and not only the immediate children of a resource
  # def save_child_associations(stop_at = nil)
  #   child_associations.each do |a|
  #     next if stop_at && stop_at == a
  #     a.save
  #     a.each do |i|
  #       unless i.send(:child_associations).empty?
  #         i.save_child_associations(stop_at)
  #       end
  #     end
  #   end
  # end
  
end

module ErrorCollecting
  
  # collect errors on parent associations
  def before_save_parent_association(association, context)
    if association.respond_to?(:each) 
      association.each { |a| before_save_parent_association(a, context) }
    else
      unless association.valid?(context)
        association.errors.each { |e| self.errors.add(:general, e) }
      end
    end
  end

  # collect errors on child associations
  def before_save_child_association(association, context)
    if association.respond_to?(:valid?)
      association.each { |a| before_save_child_association(a, context) }
    else
      self.errors.add(:general, "child association is missing")
    end
  end
  
end




describe "The way DataMapper::Associations::Relationship works:" do
  
  before :each do
    [ Person, Profile ].each { |model| model.auto_migrate! }
  end
  
  describe "assigning to the remote end of a many_to_one association" do
  
    it "should need explicit assignment to the inverse before it can be saved from the remote end" do
      
      Person.all.size.should  == 0
      Profile.all.size.should == 0
      
      # given i have a new and unsaved resource
      p = Profile.new(:nickname => 'snusnu')
      # and i assign to a many_to_one association
      p.person = Person.new(:name => 'Martin')
      # and i fetch this many_to_one relationship
      r = p.class.relationships[:person]
      # then the 'other end' of the association is loaded
      r.loaded?(p).should be_true
      # but when inversed, the 'other end' is not loaded
      r.inverse.loaded?(p.person).should be_false
      # and needs to be set before it is available
      r.inverse.set(p.person, p).should == p
      # and then it is loaded and thus ready to be saved
      r.inverse.loaded?(p.person).should be_true
      # and can be saved
      p.person.save.should be_true
      
      Person.all.size.should        == 1
      Profile.all.size.should       == 1
      
      Person.first.name.should      == 'Martin'
      Profile.first.nickname.should == 'snusnu'
      
    end
    
  end
  
end