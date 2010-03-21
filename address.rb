require 'rubygems'

gem 'dm-core', '=0.9.12'
gem 'rspec'

require 'dm-core'
require "spec"

#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

Extlib::Inflection.rule 'ess', 'esses'
#Extlib::Inflection.singular_word("address", "address")

class Person
  include DataMapper::Resource
  property :id, Serial
  has n, :addresses, :through => Resource
end

class Address
  include DataMapper::Resource
  property :id, Serial
end

describe "Inflection of 'Address'" do
  
  it "should work in DataMapper.auto_migrate!" do
    lambda { DataMapper.auto_migrate! }.should_not raise_error
  end
  
end


# mungo:Desktop snusnu$ spec -c -f -s address.rb 
# 
# Inflection of 'Address'
# - should work in DataMapper.auto_migrate!
# 
# Finished in 0.040151 seconds
# 
# 1 example, 0 failures
