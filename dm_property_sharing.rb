require "rubygems"
require "dm-core"

module Locatable  
  
  # use a lambda instead of self.included(base) class_eval hack  
  # when used inside models, it is very obvious what's going on  
  # whereas include just doesn't seem fit for an operation that  
  # will add properties to your class definition.  
  
  PROPERTIES = lambda do  
    # properties  
    property :location_id,       Integer, :nullable => false  
    # associations  
    belongs_to :location  
  end  
  
  def latitude  
    location.latitude  
  end  
  
  def longitude  
    location.longitude  
  end  
end  
  
class Item  
  include DataMapper::Resource  
  
  property :id, Serial  
  
  # makes explicit what's going on  
  # and preserves the order of properties in table  
  class_eval &Locatable::PROPERTIES  
  
  property :name,         String  
  property :description, Text  
  
  include Locatable  
  
end