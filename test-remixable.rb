require "rubygems"
require "dm-core"
require "extlib/lazy_module"
require "dm-is-remixable"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

module Addressable
  extend DataMapper::Model
  is :remixable
  property :id, Serial
  property :address, String
  has n, :phone_numbers
end

class PhoneNumber
  include DataMapper::Resource
  property :id, Serial
  property :num, Integer
  belongs_to :person_address
end

class Person
  include DataMapper::Resource
  property :id, Serial
  remix n, :addressables, :model => 'PersonAddress'
end

DataMapper.auto_migrate!

p = Person.create
a = p.person_addresses.create :address => 'foo'
a.phone_numbers.create :num => 555, :person_address_id => 1