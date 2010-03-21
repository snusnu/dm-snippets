require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-types'
require 'dm-is-remixable'

module Servy

  class User
    include DataMapper::Resource

    property :id, Serial
    property :name, String, :length => 3..32, :nullable => false
    property :password, String, :length => 6..64
    property :active, Boolean, :default => true, :nullable => false
    property :last_login, Time

    has n, :groups, :through => Resource #, :model => 'Servy::Group'
  end

  class Group
    include DataMapper::Resource

    property :id, Serial
    property :name, String, :length => 1..32, :nullable => false
    property :comment, String

    has n, :users, :through => Resource #, :model => 'Servy::User'
  end

  def self.init
    DataMapper.setup(:default, {:adapter => 'sqlite3', :database => ':memory:', :encoding => 'utf8'})
    DataMapper.auto_migrate!

    u = User.new(:name => "asdasd", :password => "********")
    u.save
    g = Group.new(:name => 'default')
    g.users << u # error here: cannot find parent_model
    g.save

    p User.all
  end
end

Servy.init