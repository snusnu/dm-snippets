require 'rubygems'
require 'spec'
require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
 
#DataMapper::Logger.new(STDOUT, :debug)
 
ENV['SQLITE3_SPEC_URI'] ||= 'sqlite3::memory:'
ENV['MYSQL_SPEC_URI'] ||= 'mysql://localhost/dm_core_test'
ENV['POSTGRES_SPEC_URI'] ||= 'postgres://postgres@localhost/dm_core_test'
 
def setup_adapter(name, default_uri = nil)
  begin
    DataMapper.setup(name, ENV["#{ENV['ADAPTER'].to_s.upcase}_SPEC_URI"] || default_uri)
    Object.const_set('ADAPTER', ENV['ADAPTER'].to_sym) if name.to_s == ENV['ADAPTER']
    true
  rescue Exception => e
    if name.to_s == ENV['ADAPTER']
      Object.const_set('ADAPTER', nil)
      warn "Could not load do_#{name}: #{e}"
    end
    false
  end
end
 
ENV['ADAPTER'] ||= 'mysql'
setup_adapter(:default)
 
module DataMapper
  module NestedAttributes
    module AssociationPersistence
      extend Chainable
 
      chainable do
        def save(*args)
          save_parents(*args) && super
        end
      end
      
      def parent_relationships
        parent_relationships = []
 
        relationships.each_value do |relationship|
          next unless relationship.respond_to?(:resource_for) && relationship.loaded?(self)
          parent_relationships << relationship
        end
 
        parent_relationships
      end
 
      def save_parents(*args)
        parent_relationships.all? do |relationship|
          parent = relationship.get(self)
          if parent.save(*args)
            relationship.set(self, parent) # set the FK values
          end
        end
      end
 
      Model.append_inclusions(self)
    end
  end
end
 
class Person
  include DataMapper::Resource
 
  property :id, Serial
  property :name, String, :nullable => false
 
  has 1, :profile
end
 
class Profile
  include DataMapper::Resource
 
  property :id, Serial
  property :nickname, String, :nullable => false
 
  belongs_to :person, :nullable => false
end
 
describe 'DataMapper::NestedAttributes::AssociationPersistence#save' do
 
  before :each do
    DataMapper.auto_migrate!
  end
 
  it 'should save a many_to_one target resource before saving self' do
 
    Profile.all.size.should == 0
    Person.all.size.should == 0
 
    profile = Profile.new(:nickname => 'snusnu')
    profile.person = Person.new(:name => 'Martin')
 
    Profile.all.size.should == 0
    Person.all.size.should == 0
 
    profile.save.should be_true
 
    Person.all.size.should == 1
    Profile.all.size.should == 1
 
  end
 
end