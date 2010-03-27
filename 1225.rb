#!/usr/bin/env ruby
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

module DataMapper
  module Migrations
    module SingletonMethods
      # Monkey patch to support overwriting Model.auto_migrate!
      # so that it will be "recognized" by DataMapper.auto_migrate!
      #
      # Fixed in:
      # http://github.com/datamapper/dm-core/commit/547627dde7bbd731eacb6c2d2f1ca623d79dcb3a
      def auto_migrate!(repository_name = nil)
        repository_execute(:auto_migrate!, repository_name)
      end
    end
  end
end

class Person
  include DataMapper::Resource

  # properties
  property :id, Serial

  def self.auto_migrate!(repository_name = self.repository_name)
    puts "Before Person.auto_migrate!"
    super
  end
  def self.auto_migrate_up!(repository_name = self.repository_name)
    puts "Before Person.auto_migrate_up!"
    super
  end
  def self.auto_migrate_down!(repository_name = self.repository_name)
    puts "Before Person.auto_migrate_down!"
    super
  end
end

DataMapper.auto_migrate!

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby 1225.rb 
Before Person.auto_migrate!
Before Person.auto_migrate_down!
 ~ (0.000051) SELECT sqlite_version(*)
 ~ (0.000068) DROP TABLE IF EXISTS "people"
Before Person.auto_migrate_up!
 ~ (0.000011) PRAGMA table_info("people")
 ~ (0.000270) CREATE TABLE "people" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
