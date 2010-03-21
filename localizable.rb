require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-is-remixable'
require 'dm-accepts_nested_attributes'
require 'dm-is-localizable'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

class Language

  include DataMapper::Resource

  property :id, Serial
  property :code, String, :nullable => false, :unique => true, :unique_index => true
  property :name, String, :nullable => false

  # locale string like 'en-US'
  validates_format :code, :with => /^[a-z]{2}-[A-Z]{2}$/

  def self.[](code)
    return nil if code.nil?
    first :code => code.to_s.gsub('_', '-')
  end

end


class Item
  include DataMapper::Resource
  property :id, Serial
  is :localizable do
    property :name, String
  end
  def default_language_code
    'en-US'
  end
end

DataMapper.auto_migrate!

l = Language.create(:code => 'en-US', :name => 'English (US)')
i = Item.create
i.name = 'foo'

puts i.inspect