require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Contact
  include DataMapper::Resource
  property :id,      Serial
  property :address, String, :length => (1..100) # test auto validation
end

describe "auto validations" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should return :key => ['error message'] when validation fails" do
    contact = Contact.new
    contact.address = ''
    contact.should_not be_valid
    contact.errors.on(:address).respond_to?(:each).should be_true # FAILS
    contact.errors.on(:address).should_not be_empty
    contact.errors.on(:address).should_not  == [ nil ]
  end
end

# mungo:snippets snusnu$ spec -cfs 853.rb 
# 
# auto validations
#  ~ (0.000153) SELECT sqlite_version(*)
#  ~ (0.000111) DROP TABLE IF EXISTS "contacts"
#  ~ (0.000022) PRAGMA table_info("contacts")
#  ~ (0.000366) CREATE TABLE "contacts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "address" VARCHAR(100) NOT NULL)
# - should return :key => ['error message'] when validation fails
# 
# Finished in 0.00581 seconds
# 
# 1 example, 0 failures

