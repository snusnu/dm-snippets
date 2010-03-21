require 'rubygems'
require 'dm-core'
require 'dm-validations'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :type, Discriminator
  property :val, Integer
end

class LazyTextbox < Element
  property :content, Text, :lazy => false
  validates_present :content
end

class ActiveTextbox < Element
  property :content, Text
  validates_present :content
end

class LazyUnvalidatedTextbox < Element
  property :content, Text, :lazy => false
end

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/content.db")

DataMapper.auto_upgrade!

lazy = LazyTextbox.create({:val => 10, :content => 'hello'})
active = ActiveTextbox.create({:val => 10, :content => 'hello'})
unvalid = LazyUnvalidatedTextbox.create({:val => 10, :content => 'hello'})


# Doesn't work!
e = Element.get lazy.id
e.val = 20
puts e.save
puts e.val

# Works when accessing the child class
e = LazyTextbox.get lazy.id
e.val = 20
puts e.save
puts e.val

# Works when not lazy loaded
e = Element.get active.id
e.val = 20
puts e.save
puts e.val

# Works when not validated
e = Element.get unvalid.id
e.val = 20
puts e.save
puts e.val
