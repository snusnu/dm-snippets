require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-accepts_nested_attributes'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Parent
  include DataMapper::Resource

  property :id,           Serial
  property :string_field, String, :length => 5
  has n, :children, 'Child'
end

class Child
  include DataMapper::Resource

  property :id,        Serial
  property :parent_id, Integer
  belongs_to :parent

  accepts_nested_attributes_for :parent
end

Parent.auto_migrate!
Child.auto_migrate!

puts '-'*80

c = Child.new
c.parent_attributes = {:string_field => 'long string'}
c.save

puts "parents  = #{Parent.all.inspect}"
puts "children = #{Child.all.inspect}"