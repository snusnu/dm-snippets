require 'rubygems'
require 'dm-core'

include DataMapper::Types

class Root
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :type, Discriminator
end

class Branch < Root
  property :value, Integer
end

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

branch_one = Branch.new
branch_one.name = "branch one"
branch_one.value = 42

branch_one.save

entities = Root.all

p entities[0].value