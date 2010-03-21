require 'rubygems'
require 'dm-core'
require 'spec'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup :default, "sqlite3::memory:"

class User
  include DataMapper::Resource
   
  property :id,     Serial
  property :active, Boolean

  default_scope(:default).update(:active => true)

  auto_migrate!
end

describe "Overwriting default scope conditions" do
  before :all do
    @active   = User.create(:active => true)
    @inactive = User.create(:active => false)
  end

  it "should overwrite a condition" do
    users = User.all(:active => false)

    users.size.should == 1
    users.first.should == @inactive
  end
end

