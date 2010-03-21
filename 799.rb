require 'rubygems'
require 'dm-core'
require 'dm-is-state_machine'

DataMapper.setup(:default, "sqlite3://memory")

class LightSwitch
  include DataMapper::Resource
  property :id, Serial
  property :type, Discriminator
 
  is :state_machine, :initial => :off do
    state :off
    state :on, :enter => :on_hook
  
    event :switch do
      transition :from => :on, :to => :off
      transition :from => :off, :to => :on
    end
  end

  def on_hook
    puts "Light turned on!"
  end
end

class WorkingLightSwitch < LightSwitch
  # after explicitly setting @is_state_machine, things work as expected
  @is_state_machine = superclass.instance_variable_get(:@is_state_machine)
  def on_hook
    puts "This one works."
  end
end

class ExplodingLightSwitch < LightSwitch
  def on_hook
    puts "Boom goes the dynamite!"
  end
end



DataMapper.auto_migrate!

ls = LightSwitch.new
ls.switch! #=> "Light turned on!"

wls = WorkingLightSwitch.new
wls.switch! #=> "This one works."

els = ExplodingLightSwitch.new
els.switch! # undefined method `[]' for nil:NilClass (NoMethodError)
