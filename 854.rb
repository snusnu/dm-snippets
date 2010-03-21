require "rubygems"
require "dm-core"
require "dm-validations"

require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")


class Contact
   include DataMapper::Resource
   property :id,    Serial
   property :label, String
   validates_within :label, :set => ["one", "two"], :message=>"Invalid label"
end

describe "validates_within" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should allow to overwrite the default error message" do
    contact = Contact.new
    contact.valid?
    contact.errors.on(:label).should == ["Invalid label"]
  end
end

# mungo:snippets snusnu$ spec -cfs 854.rb 
# 
# validates_within
#  ~ (0.000151) SELECT sqlite_version(*)
#  ~ (0.000108) DROP TABLE IF EXISTS "contacts"
#  ~ (0.000027) PRAGMA table_info("contacts")
#  ~ (0.000371) CREATE TABLE "contacts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "label" VARCHAR(50))
# - should allow to overwrite the default error message
# 
# Finished in 0.005372 seconds
# 
# 1 example, 0 failures
