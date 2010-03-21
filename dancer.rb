#!/usr/bin/env ruby
#
# A one file test to show ...
require 'rubygems'
require 'dm-core'
require 'dm-validations'

# setup the logger
DataMapper::Logger.new(STDOUT, :debug)

# connect to the DB
DataMapper.setup(:default, 'sqlite3::memory:')

class TestModel
  include DataMapper::Resource

  # properties
  property :id, Serial
  property :title, String, :length => (10..100)

end

DataMapper.auto_migrate!

test_model = TestModel.new
test_results = Array.new

#1. title set to nil
test_model.title = nil
test_results << test_model.valid?

#2. title set to ""
test_model.title = ""
test_results << test_model.valid?

#3. title set to "Hello!"
test_model.title = "Hello!"
test_results << test_model.valid?

#4. title set to "Hello World!"
test_model.title = "Hello World!"
test_results << test_model.valid?

puts ""
puts "The following results are from a model in which :length => (10..100) is set on title"
puts ""
puts "When title is set to nil #valid? returns #{test_results[0]}"
puts "When title is set to \"\" #valid? returns #{test_results[1]}"
puts "When title is set to \"Hello!\" #valid? returns #{test_results[2]}"
puts "When title is set to \"Hello World!\" #valid? returns #{test_results[3]}"