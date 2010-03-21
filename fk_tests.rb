require 'rubygems'
require 'dm-core'
require 'dm-constraints'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/fk_tests')

class Category

  include DataMapper::Resource

  property :id,        Serial
  property :parent_id, Integer, :unique => true, :unique_index => :foo, :min => 0
  property :name,      String,  :unique => true, :unique_index => :foo, :required => true

  belongs_to :parent, self

end

DataMapper.auto_migrate!

c1   = Category.create :name => 'c1'
c2   = Category.create :name => 'c2'
c1_1 = Category.create :name => 'c1_1', :parent => c1
c1_1 = Category.create :name => 'c1_1'
c1_1 = Category.create :name => 'c2_1', :parent => c2

__END__
