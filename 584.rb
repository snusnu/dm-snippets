require "rubygems"
require "dm-core"
require "dm-types"
require "dm-aggregates"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Issue
  include DataMapper::Resource
  property :id,          Serial
  property :status,      Enum[:new, :open, :closed, :invalid], :default => :new
  property :name,        String
  property :description, Text
end


describe "dm-aggregates working on an Enum property" do
  before(:all) do
    DataMapper.auto_migrate!
  end
  it "should return :key => ['error message'] when validation fails" do
    c1 = Issue.create :status => :open, :name => 'foo', :description => 'foots'
    c2 = Issue.create :status => :open, :name => 'bar', :description => 'barts'
    result = Issue.all(:status => :open).aggregate(:status.count, :fields => [:name, :description])
    
    puts result.inspect
  end
end