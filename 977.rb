require 'rubygems'
 
USE_DM_0_9 = false
 
if USE_DM_0_9
  DM_GEMS_VERSION   = "0.9.11"
  DO_GEMS_VERSION   = "0.9.12"
else
  DM_GEMS_VERSION   = "0.10.0"
  DO_GEMS_VERSION   = "0.10.0"
end

gem "dm-core",         DM_GEMS_VERSION   
gem "dm-timestamps",   DM_GEMS_VERSION

require "dm-core"
require "dm-timestamps"

require 'spec'
 
SQLITE_FILE = File.join(`pwd`.chomp, "test.db")
 
DataMapper.setup(:default, "sqlite3:#{SQLITE_FILE}")
DataMapper.setup(:reloaded, "sqlite3:#{SQLITE_FILE}")
 
class Parent
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :nullable => false
  
  property :created_at, Time
  property :updated_at, Time
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
    Parent.auto_migrate!
  end
  
  config.before(:each) do    
    DataMapper::Repository.context << repository(:default)
  end
  
  config.after(:each) do
    DataMapper::Repository.context.pop
  end
end
 
describe Parent, "with timestamps" do
  it "should set the timestamps for a #new object" do
    @parent = Parent.new
    @parent.created_at.should_not be_nil
  end
  
  it "behaves correctly for #create" do
    @parent = Parent.create(:name => "Homer")
    @parent.created_at.should_not be_nil
  end
end