#!/usr/bin/ruby

require 'rubygems'
require 'dm-core'

class Author
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :firstname, String
  property :lastname, String

  has n, :books, :type => 'fiction', :child_key => [:firstname, :lastname], :parent_key => [:firstname, :lastname]
end

class Book
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :name, String
  property :type, String
  property :firstname, String
  property :lastname, String

  belongs_to :author, :child_key => [:firstname, :lastname], :parent_key => [:firstname, :lastname]
end

class Capture
  def initialize
    @log = []
  end
  def write str
    @log << str
  end

  attr_reader :log
end

capture = Capture.new
DataMapper.logger = DataMapper::Logger.new(capture, 0)
DataMapper.setup(:default, 'sqlite3://memory')
DataMapper.auto_migrate!

john = Author.create(:firstname => 'John', :lastname => 'Doe')
jane = Author.create(:firstname => 'Jane', :lastname => 'Doe')

book = Book.create(:name => 'Funk and Rock', :firstname => 'Jane', :lastname => 'Doe', :type => 'fiction')

authors = Author.all
authors.books.length

expected = %q{SELECT "id", "name", "type", "firstname", "lastname" FROM "books" WHERE ("type" = 'fiction') AND ((("firstname" = 'John') AND ("lastname" = 'Doe')) OR (("firstname" = 'Jane') AND ("lastname" = 'Doe'))) ORDER BY "id"}

sql = capture.log.pop.sub(/^.*SELECT/, 'SELECT').strip
puts sql == expected