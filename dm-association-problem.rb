require 'rubygems'
require 'test/unit'
require 'dm-core'

DataMapper.setup(:default, "sqlite3::memory:")

class MegaMan
  include DataMapper::Resource
  has n, :arm_cannons

  property :id,          Serial
  property :name,        String

  def power(date = Date.today)
    cannon = arm_cannons.first(
      :acquired.lte => date,
      :order => [:acquired.desc])
    cannon.power
  end
end

class ArmCannon
  include DataMapper::Resource

  belongs_to :mega_man

  property :id,          Serial
  property :power,       String, :nullable => false
  property :acquired,    Date, :nullable => false, :default => Date.today
end

class TestMegaCannons < Test::Unit::TestCase
  def setup
    DataMapper.auto_migrate!
    m1 = MegaMan.new(:name => "Mega Man")
    m1.arm_cannons << ArmCannon.new(:power => "Buster")
    m1.save

    m2 = MegaMan.new(:name => "Rock Man")
    m2.arm_cannons << ArmCannon.new(:power => "Ice Slasher")
    m2.save
  end

  ## All megaman have Busters??
  def test_current_budget_BUG
    cannons = [ "Buster", "Ice Slasher" ]
    MegaMan.all.each do |m|
      assert_equal cannons.shift, m.power
    end
  end

  ## Test passes when not iterating over all mega men?
  def test_current_budget
    assert_equal "Buster", MegaMan.first(:name => "Mega Man").power
    assert_equal "Ice Slasher", MegaMan.first(:name => "Rock Man").power
  end
end
