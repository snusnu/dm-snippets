require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'spec'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/test.db")
DataObjects::Sqlite3.logger = DataObjects::Logger.new(STDOUT, 0)

class Foo
  include DataMapper::Resource
  property :id, Serial
  property :foo, Integer, :format => /[0-9]+/
end

describe ":format validation on numerical values " do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should allow to validate numerical values" do
    f = Foo.new(:foo => 33)
    f.save.should be_true
    f.errors.should be_empty
  end
end

# mungo:snippets snusnu$ spec -cfs 859.rb 
# 
# :format validation on numerical values 
# Thu, 09 Jul 2009 22:19:31 GMT ~ debug ~ (0.000143) SELECT sqlite_version(*)
# Thu, 09 Jul 2009 22:19:31 GMT ~ debug ~ (0.003289) DROP TABLE IF EXISTS "foos"
# Thu, 09 Jul 2009 22:19:31 GMT ~ debug ~ (0.000036) PRAGMA table_info("foos")
# Thu, 09 Jul 2009 22:19:31 GMT ~ debug ~ (0.001744) CREATE TABLE "foos" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "foo" INTEGER)
# - should allow to validate numerical values (FAILED - 1)
# 
# 1)
# ':format validation on numerical values  should allow to validate numerical values' FAILED
# expected true, got false
# ./859.rb:21:
# 
# Finished in 0.010991 seconds
# 
# 1 example, 1 failure
