require "rubygems"
require "dm-core"
require "dm-validations"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Contact
  include DataMapper::Resource
  property :id,      Serial
  property :zip,     String
  property :address, String, :length => (1..100)
end

describe "auto validations" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should return :key => ['error message'] when validation fails" do
    contact = Contact.new
    contact.should_not be_valid # <-- FAILS
    contact.errors.on(:address).respond_to?(:each).should be_true
    contact.errors.on(:address).should_not be_empty
  end
end

# mungo:snippets snusnu$ spec -cfs 968.rb 
# 
# auto validations
#  ~ (0.000159) SELECT sqlite_version(*)
#  ~ (0.000117) DROP TABLE IF EXISTS "contacts"
#  ~ (0.000022) PRAGMA table_info("contacts")
#  ~ (0.000372) CREATE TABLE "contacts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "zip" VARCHAR(50), "address" VARCHAR(100))
# - should return :key => ['error message'] when validation fails (FAILED - 1)
# 
# 1)
# 'auto validations should return :key => ['error message'] when validation fails' FAILED
# expected valid? to return false, got true
# ./968.rb:22:
# 
# Finished in 0.00581 seconds
# 
# 1 example, 1 failure



@nullable     = if options[:length].is_a?(Range) && options[:length].min > 0
  false
else
  @options.fetch(:nullable, @key == false)
end


it 'returns false when lower bound of length range is greater than zero' do
  Image.properties[:description].nullable?.should be_false
end
