require 'rubygems'
require 'dm-core'
data_dir = "."

DataMapper::Logger.new(STDOUT, :debug)

# currently you need to setup a :default repository
DataMapper.setup(:default, "sqlite3::memory:")

DataMapper.setup(:development, "sqlite3::memory:")
DataMapper.setup(:production, "sqlite3::memory:")

class Bank

  include DataMapper::Resource

  # properties in default repository will be
  # inherited by all the other repositories
  property :cert, Integer, :key => true

  repository(:development) do
    property :new_cert,    Integer
    property :parent_cert, Integer
  end

  repository(:production) do
    # change field of the cert key only in this repository
    property :cert, Integer, :key => true, :field => 'id'
    property :url,  String
  end

end

Bank.auto_migrate!(:development)
Bank.auto_migrate!(:production)

if $0 == __FILE__
  puts "Development repo"
  Bank.properties(:development).each {|x| puts x.inspect }
  puts "Production repo"
  Bank.properties(:production).each {|x| puts x.inspect }
end

