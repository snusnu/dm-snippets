require 'rubygems'
require 'dm-core'
require 'dm-validations'

DataMapper.setup(:default, 'sqlite3::memory:')

class Bugtest
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :unique => true
  has n, :bars
  has n, :foos, :through => :bars
end

class Bar
  include DataMapper::Resource
  property :id, Serial
  belongs_to :bugtest
  belongs_to :foo
end

class Foo
  include DataMapper::Resource
  property :id, Serial
  has n, :bars
  has n, :bugtests, :through => :bars
end

DataMapper.auto_migrate!

bug = Bugtest.create(:name => "foo")
bug.foos << bug
bug.save