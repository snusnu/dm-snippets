#!/usr/bin/env ruby

# get and manipulate the offset of a UTC time
# (Time.parse("2009-03-30T18:11:29").to_datetime.new_offset(Rational(4,24)).offset * 24).to_i
# => 4

require 'rubygems'
  
gem 'dm-core',       '=0.9.10'
gem 'dm-types',      '=0.9.10'
gem 'dm-timestamps', '=0.9.10'

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'

DataMapper::Logger.new(STDOUT, :debug)

#DataMapper.setup(:default, 'sqlite3:memory:')
DataMapper.setup(:default, 'mysql://localhost/playground')

module DataMapper
  module Types
    
    class UtcDateTime < DataMapper::Type
      
      primitive DateTime

      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(DateTime)
          ::DateTime.new(value.year, value.month, value.day, value.hour, value.min, value.sec, 0)
        else
          raise ArgumentError.new("+value+ must be nil or a DateTime")
        end
      end

      def self.dump(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          Time.parse(value).utc.to_datetime
        elsif value.is_a?(DateTime)
          Time.parse(value.to_s).utc.to_datetime
        else
          raise ArgumentError.new("+value+ must be nil or a String or a DateTime")
        end
      end
      
    end # class UtcDateTime
    
    UTCDateTime = UtcDateTime
  
  end # module Types
end # module DataMapper


module DataMapper
  module Timestamp
    
    def set_timestamps
      return unless dirty? || new_record?
      TIMESTAMP_PROPERTIES.each do |name,(_type,proc)|
        if model.properties.has_property?(name)
          self.send("#{name}=", proc.call(self, model.properties[name]))
        end
      end
    end
    
    def utc_timestamped?
      self.class.utc_timestamped?
    end
    
    module ClassMethods
      
      def timestamps(*names)
        raise ArgumentError, 'You need to pass at least one argument' if names.empty?
        
        # if the last element in names is a Hash:
        # extract this hash and look for a :utc key
        opts = names.last.is_a?(Hash) ? names.pop : nil
        @utc = opts && opts[:utc]) && (names.include?(:created_at) || names.include?(:updated_at)

        names.each do |name|
          case name
            when *TIMESTAMP_PROPERTIES.keys
              type = TIMESTAMP_PROPERTIES[name].first
              property name, type, :nullable => false, :auto_validation => false
              
              if type == DateTime && @utc # UTC makes no sense for Date
                define_method "#{name}=", UTC::PROPERTY_WRITER.call(name, type)
                define_method "#{name}",  UTC::PROPERTY_READER.call(name, type)
              end
            
            when :at
              timestamps(:created_at, :updated_at, :utc => @utc)
            when :on
              timestamps(:created_on, :updated_on) # UTC makes no sense for Date
            else
              raise InvalidTimestampName, "Invalid timestamp property name '#{name}'"
          end
        end
      end
      
      def utc_timestamped?
        !!@utc
      end
      
    end
    
    module UTC
      PROPERTY_WRITER = lambda { |name, type|
        lambda { |dt| attribute_set(name, Time.parse(dt.to_s).utc.send("to_#{type.name.downcase}")) } 
      }
      PROPERTY_READER = lambda { |name, type|
        lambda {
          return nil unless dt = attribute_get(name)
          if type == Date
            Date.new(dt.year, dt.month, dt.day, 0)
          elsif type == DateTime
            DateTime.new(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec, 0)
          else
            nil
          end
        }
      }
    end
    
  end
end



class Booking  
  
  include DataMapper::Resource
  
  property :id,    Serial
  property :start, DateTime
  
  timestamps :at, :utc => true
  
  def start=(d)
    attribute_set(:start, d.is_a?(String) ? Time.parse(d).to_datetime : d)
  end
  
end

def add_minutes(date_time, minutes)
  (date_time.to_time + minutes * 60).to_datetime
end

Booking.auto_migrate!

b1 = Booking.create :start => '2009-03-30-00:00:00 GMT+0100 (CET)'
b2 = Booking.create :start => add_minutes(b1.start, 540)
b3 = Booking.create :start => add_minutes(b2.start, 0)
b4 = Booking.create :start => add_minutes(b3.start, 540)

Booking.all.each do |b|
  puts "id = #{b.id}, created_at = #{b.created_at}, start = #{b.start.to_s}"
end



class Item
  
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String
  
  property :start, UTCDateTime
  
end

Item.auto_migrate!

i1 = Item.create :name => "item01", :start => '2009-03-28T12:00:00+01:00'
i1 = Item.create :name => "item01", :start => '2009-03-29T12:00:00+01:00'
i1 = Item.create :name => "item01", :start => '2009-03-30T12:00:00+01:00'

Item.all.each do |i|
  puts "id = #{i.id}, name = #{i.name}, start = #{i.start.to_s}"
end


















i = Item.get(16)
b = Booking.get(23)
sd = DateTime.parse("2009-03-27 08:00:00")
o = 1980
d = 120
q = 9
puts "occupied_items_count  = #{Booking.occupied_items_count(sd, i, o, d, q, 'pending')}"
puts "available_items_count = #{Booking.available_items_count(sd, i, o, d, q, 'pending')}"
puts "capacities_available? = #{Booking.capacities_available?(sd, i, o, d, q, 'pending')}"


# 
#           1                          2                        3              ........ quantity
# +--------------------+    +--------------------+    +--------------------+
# | +----------------+ |    | +----------------+ |    | +----------------+ |
# | |                | |    | |                | |    | |                | |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |   ........ offset
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |
# | +---++++++++++---+ |    | +---++++++++++---+ |    | +---++++++++++---+ |           |
# |     ++++++++++     |    |     ++++++++++     |    |     ++++++++++     |           |
# | +---++++++++++---+ |    | +---++++++++++---+ |    | +---++++++++++---+ |           |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |]
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |] duration
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |]
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |
# | +---++++++++++---+ |    | +---++++++++++---+ |    | +---++++++++++---+ |           |
# |     ++++++++++     |    |     ++++++++++     |    |     ++++++++++     |           |
# | +---++++++++++---+ |    | +---++++++++++---+ |    | +---++++++++++---+ |           |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |           |
# | |   ++++++++++   | |    | |   ++++++++++   | |    | |   ++++++++++   | |   ........ offset + duration
# | |                | |    | |                | |    | |                | |
# | +----------------+ |    | +----------------+ |    | +----------------+ |
# +--------------------+    +--------------------+    +--------------------+

SELECT COUNT(*) 
FROM `bookings` 
WHERE (`deleted_at` IS NULL) AND (`item_id` = 16 AND `status` = 'confirmed') AND 
(
  (`scheduled_start` <= '2009-03-30T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-03-30T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-03-30T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-03-30T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-03-31T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-03-31T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-03-31T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-03-31T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-01T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-01T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-01T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-01T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-02T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-02T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-02T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-02T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-03T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-03T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-03T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-03T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-04T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-04T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-04T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-04T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-05T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) >= 2100) OR
  (`scheduled_start` <= '2009-04-05T00:00:00+00:00' AND `offset` <= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-05T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) <= 2100) OR
  (`scheduled_start` >= '2009-04-05T00:00:00+00:00' AND `offset` >= 1980 AND (`offset` + `duration`) >= 2100)
)