require 'rubygems'
 
require 'dm-core'
require 'spec'
require 'spec/autorun'
 
SQLITE_FILE = File.join(`pwd`.chomp, "test.db")
 
DataMapper.setup(:default, "sqlite3:#{SQLITE_FILE}")
DataMapper.setup(:reloaded, "sqlite3:#{SQLITE_FILE}")

class Parent
  include DataMapper::Resource
  property :id, Serial
  has n, :debts
end
  
class Debt
  include DataMapper::Resource
  property :id, Serial
  belongs_to :parent
end
 

Spec::Runner.configure do |config|
  config.before(:each) do
    Parent.auto_migrate!
    Debt.auto_migrate!
  end
  
  config.before(:each) do    
    DataMapper::Repository.context << repository(:default)
  end
  
  config.after(:each) do
    DataMapper::Repository.context.pop
  end
end
 
describe Parent, "with debts, 1 to n" do
  before(:each) do
    @parent = Parent.new
    @parent.debts << Debt.new(:parent => @parent)
    @parent.save    
  end
  
  it "1 to n associations appears to be sharing associations across an identity map" do
    repository(:reloaded) do
      parent_reloaded = Parent.get(@parent.id)
      first_debt = parent_reloaded.debts.first
      Debt.get(first_debt.id).repository.name.should == first_debt.repository.name
    end
  end
end
