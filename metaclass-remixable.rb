require "rubygems"
require "dm-core"
require "spec"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

module Remixable
  def is_remixable
    name = Extlib::Inflection.demodulize(self.name).snake_case.to_sym
    (class << self; self end).send(:include, Remixee)
    (Remixable.descendants[name] ||= {})[:module] = self
  end

  def self.descendants
    @descendants ||= {}
  end

  module Remixee
    
    [ :property, :belongs_to, :has ].each do |name|

      class_eval <<-RUBY
        def #{name}(*args)             # def property(*args)
          #{name}_declarations << args #   property_declarations << args
        end                            # end

        def #{name}_declarations       # def property_declarations
          @#{name}_declarations ||= [] #   @property_declarations ||= []
        end                            # end
      RUBY

    end

  end
end

module Addressable
  extend DataMapper::Model
  extend Remixable
  is :remixable
  property :id,         Serial
  property :address,    String,  :nullable => false
  belongs_to :country
  belongs_to :profile, :nullable => true
  has n, :phone_numbers, 'Phone'
end

class Phone
  include DataMapper::Resource
  property :id,         Serial
  property :address_id, Integer, :nullable => false
  property :number,     String
end

describe "metaclass remixables" do

  it "should not alter the common Module namespace" do
    Module.respond_to?(:property).should   be_false
    Module.respond_to?(:belongs_to).should be_false
    Module.respond_to?(:has).should        be_false
  end


  it "should provide the property method in the remixable module" do
    Addressable.respond_to?(:property).should be_true
  end
  it "should provide the belongs_to method in the remixable module" do
    Addressable.respond_to?(:belongs_to).should be_true
  end
  it "should provide the has method in the remixable module" do
    Addressable.respond_to?(:has).should be_true
  end


  it "should provide the property_declarations method" do
    Addressable.respond_to?(:property_declarations).should be_true
  end
  it "should provide the belongs_to_declarations method" do
    Addressable.respond_to?(:belongs_to_declarations).should be_true
  end
  it "should provide the has_declarations method" do
    Addressable.respond_to?(:has_declarations).should be_true
  end

  it "should store all property declarations" do
    Addressable.property_declarations.size.should == 2
    Addressable.property_declarations.should include([ :id,      DataMapper::Types::Serial       ])
    Addressable.property_declarations.should include([ :address, String,  { :nullable => false } ])
  end
  it "should store all belongs_to declarations" do
    Addressable.belongs_to_declarations.size.should == 2
    Addressable.belongs_to_declarations.should include([ :country ])
  end
  it "should store all has declarations" do
    Addressable.has_declarations.should_not be_empty
  end

  it "should store its descendants" do
    Remixable.descendants.size.should == 1
  end
  it "should follow naming conventions for storing descendants" do
    Remixable.descendants[:addressable][:module].should == Addressable
  end
end