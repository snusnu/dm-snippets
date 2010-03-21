require 'rubygems'
require 'dm-core'

class Foo
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has 1, :bar
  has n, :bazs
end

class Bar
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :nullable => false

  belongs_to :foo, :nullable => true
end

class Baz
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  belongs_to :foo
end

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

baz1 = Baz.new(:name => 'baz1')
baz2 = Baz.new(:name => 'baz2')

foo = Foo.new(:name => 'foo')

foo.bazs.new(baz1.attributes)
foo.bazs.new(baz2.attributes)

bar = Bar.create(:name => 'bar', :foo => foo)

p bar.dirty? # true

bar.name = 'hey'

p bar.dirty? # true

p bar.save # true

bar.reload

p bar.dirty? # true, whether you reload or not