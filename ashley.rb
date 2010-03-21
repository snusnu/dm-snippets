
require 'rubygems'
  
USE_DM_0_9 = false
 
if USE_DM_0_9
  DM_GEMS_VERSION   = "0.9.11"
  DO_GEMS_VERSION   = "0.9.12"
else
  DM_GEMS_VERSION   = "0.10.0"
  DO_GEMS_VERSION   = "0.10.0"
end
 
gem "data_objects",   DO_GEMS_VERSION
gem "do_sqlite3",     DO_GEMS_VERSION # If using another database, replace this
gem "dm-core",        DM_GEMS_VERSION   
gem "dm-types",       DM_GEMS_VERSION        
gem "dm-validations", DM_GEMS_VERSION  

require "data_objects"
require "dm-core"
require "dm-aggregates"
require "dm-migrations"
require "dm-timestamps"
require "dm-types"
require "dm-validations"
require "dm-serializer"

require 'spec'
 
SQLITE_FILE = File.join(`pwd`.chomp, "test.db")
 
DataMapper.setup(:default, "sqlite3:#{SQLITE_FILE}")
DataMapper.setup(:reloaded, "sqlite3:#{SQLITE_FILE}")
 
class Parent
  include DataMapper::Resource

  property :id, Serial
  
  has n, :children
end
 
class Child
  include DataMapper::Resource

  property :id, Serial
  
  belongs_to :parent
  has n, :pets
end
 
module IdentityMapHelper
  def reload(object)
    object.class.get(object.id)
  end
  
  def with_db_reconnect(&blk)
    original_repository = DataMapper::Repository.context.pop
    repository(:reloaded, &blk)
    DataMapper::Repository.context << original_repository
  end
end
 
Spec::Runner.configure do |config|
  include IdentityMapHelper
  
  config.before(:each) do
    DataMapper.auto_migrate!
  end
  
  config.before(:each) do    
    DataMapper::Repository.context << repository(:default)
  end
  
  config.after(:each) do
    DataMapper::Repository.context.pop
  end
end

describe "Child with unsaved parent" do
  before(:each) do
    @child = Child.new
    @parent = Parent.new
    
    @parent.children << @child
  end
  
  it "should define a new child with an assigned but unsaved parent as valid" do
    @parent.should be_valid
    @child.should be_valid
  end  
  
  it "works when you save the parent" do
    @parent.should be_valid
    @parent.save
    @parent.should be_valid
    @child.should be_valid
  end  
end
