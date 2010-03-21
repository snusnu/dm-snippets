require 'rubygems'
  
gem 'dm-core',         '=0.9.11'
gem 'dm-is-remixable', '=0.9.11'

require 'dm-core'
require 'dm-is-remixable'

DataMapper::Logger.new(STDOUT, :debug)

DataMapper.setup(:default, 'sqlite3:memory:')

module Foo
  include DataMapper::Resource
  is :remixable
  property :id,  Serial
  property :foo, String
  module RemixeeInstanceMethods
    def foo=(v)
      puts "called overwritten #{self.class.name}#foo="
    end
    def foo
      puts "called overwritten #{self.class.name}#foo"
    end
  end
end

# doesn't work
class Bar
  include DataMapper::Resource
  property :id, Serial
  remix n, :foos
end

# doesn't work
class Baz
  include DataMapper::Resource
  property :id, Serial
  remix n, :foos
  enhance :foos do
    include Foo::RemixeeInstanceMethods
  end
end

# THIS WORKS
# but isn't really desireable since i want to define
# the shared logic in one place, and not in all clients
# of the remixable module
class Bam
  include DataMapper::Resource
  property :id, Serial
  remix n, :foos
  enhance :foos do
    def foo=(v)
      puts "called enhanced #{self.class.name}#foo="
    end
    def foo
      puts "called enhanced #{self.class.name}#foo"
    end
  end
end

Bar.auto_migrate!
Baz.auto_migrate!
Bam.auto_migrate!

BarFoo.auto_migrate!
BazFoo.auto_migrate!
BamFoo.auto_migrate!

b = Bar.create

puts
puts "expecting: BarFoo#foo and BarFoo#foo="
puts "-------------------------------------"
bf = BarFoo.new
bf.foo
bf.foo = "foo"

puts
puts "expecting: BazFoo#foo and BazFoo#foo="
puts "-------------------------------------"
bf = BazFoo.new
bf.foo
bf.foo = "foo"

puts
puts "expecting: BamFoo#foo and BamFoo#foo="
puts "-------------------------------------"
bf = BamFoo.new
bf.foo
bf.foo = "foo"

# mungo:trippings snusnu$ ruby ../../Desktop/remixable.rb 
# Tue, 31 Mar 2009 02:00:41 GMT ~ info ~ Generating Remixed Model: BarFoo
# Tue, 31 Mar 2009 02:00:41 GMT ~ info ~ Generating Remixed Model: BazFoo
# Tue, 31 Mar 2009 02:00:41 GMT ~ info ~ Generating Remixed Model: BamFoo
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.003555) DROP TABLE IF EXISTS "bars"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000104) PRAGMA table_info('bars')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000036) SELECT sqlite_version(*)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002571) CREATE TABLE "bars" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.004250) DROP TABLE IF EXISTS "bazs"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000021) PRAGMA table_info('bazs')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002077) CREATE TABLE "bazs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002335) DROP TABLE IF EXISTS "bams"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000026) PRAGMA table_info('bams')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002980) CREATE TABLE "bams" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.001990) DROP TABLE IF EXISTS "bar_foos"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000020) PRAGMA table_info('bar_foos')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.003108) CREATE TABLE "bar_foos" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "foo" VARCHAR(50), "bar_id" INTEGER NOT NULL)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002462) DROP TABLE IF EXISTS "baz_foos"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000035) PRAGMA table_info('baz_foos')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002796) CREATE TABLE "baz_foos" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "foo" VARCHAR(50), "baz_id" INTEGER NOT NULL)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002167) DROP TABLE IF EXISTS "bam_foos"
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.000017) PRAGMA table_info('bam_foos')
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002434) CREATE TABLE "bam_foos" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "foo" VARCHAR(50), "bam_id" INTEGER NOT NULL)
# Tue, 31 Mar 2009 02:00:41 GMT ~ debug ~ (0.002933) INSERT INTO "bars" DEFAULT VALUES
# 
# expecting: BarFoo#foo and BarFoo#foo=
# -------------------------------------
# called overwritten BarFoo#foo=
# 
# expecting: BazFoo#foo and BazFoo#foo=
# -------------------------------------
# called overwritten BazFoo#foo=
# 
# expecting: BamFoo#foo and BamFoo#foo=
# -------------------------------------
# called enhanced BamFoo#foo
# called enhanced BamFoo#foo=


