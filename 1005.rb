require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :default)
DataMapper.setup(:legacy, 'sqlite3::memory:')

class WorkingArchive

  include DataMapper::Resource

  def self.default_repository_name
    :legacy
  end

  property :id,           Serial
  property :archive_name, String, :nullable => false
  property :archive_info, String, :nullable => false
  property :archive_url,  String, :nullable => false

end

# class FailingArchive
# 
#   include DataMapper::Resource
# 
#   property :id,           Serial
#   property :archive_name, String, :nullable => false
#   property :archive_info, String, :nullable => false
#   property :archive_url,  String, :nullable => false
# 
#   def self.default_repository_name
#     :legacy
#   end
# 
# end

DataMapper.auto_migrate!


