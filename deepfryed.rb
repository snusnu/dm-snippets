#!/usr/bin/ruby

require 'rubygems'
require 'dm-core'

class Author
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :name, String
  property :code, String
  property :country, String

  has n, :books, :type => 'fiction', :child_key => [:code, :country], :parent_key => [:code, :country]
end

class Book
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :name, String
  property :type, String
  property :code, String
  property :country, String

  belongs_to :author, :child_key => [:code, :country], :parent_key => [:code, :country]
end

DataMapper.logger = DataMapper::Logger.new(STDERR, 0)
DataMapper.setup(:default, 'sqlite3://memory')
DataMapper.auto_migrate!

john = Author.create(:name => 'John Doe', :code => 1, :country => 'au')
jane = Author.create(:name => 'Jane Doe', :code => 2, :country => 'au')

book = Book.create(:name => 'Foo Bar', :code => 1, :country => 'au', :type => 'fiction')

authors = Author.all
authors.each {|a| p a.books }