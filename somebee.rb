# encoding: utf-8

require 'rubygems'
require 'dm-core'
 
DataMapper.setup(:default,
  :adapter => 'mysql',
  :host => 'localhost', 
  :username => 'root',
  :database => 'dm_core_test',
  :encoding => 'utf-8'
)
 
DataObjects::Mysql.logger = DataObjects::Logger.new(STDOUT, :debug)

class Company
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  has n, :invoices, :child_key => [:owner_id]
end

class Invoice
  include DataMapper::Resource
  
  property :id, Serial
  property :nr, Integer
  belongs_to :owner, :model => "Company", :child_key => [:owner_id]
end

DataMapper.auto_migrate!
