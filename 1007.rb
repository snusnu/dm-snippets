#!/usr/bin/env ruby

require 'rubygems'
require 'dm-core'


class Person
  include DataMapper::Resource

  property :id       , Serial
  property :name     , String
  property :age      , Integer  

  belongs_to :city

  repository(:es) do
    storage_names[:es] = 'personas'
    property :name   , String  , :field => 'nombre'
    property :age    , Integer , :field => 'edad'
  end

  repository(:fr) do
    storage_names[:fr] = 'personnes'
    property :name   , String  , :field => 'nom'
  end
end


class City
  include DataMapper::Resource  

  property :id       , Serial   
  property :name     , String   

  has n, :people

  repository(:es) do
    storage_names[:es] = 'ciudads'
    property :name   , String , :field => 'nombre'
  end

  repository(:fr) do
    storage_names[:fr] = 'villes'
    property :name   , String , :field => 'nom'
  end
end


require 'test/unit'
class TC_Repositories < Test::Unit::TestCase

  def setup

    DataMapper.setup(:default , "sqlite3:///#{Dir.pwd}/default.db")

    DataMapper.setup(:es, "sqlite3:///#{Dir.pwd}/es.db")
    City.auto_migrate!(:es)
    Person.auto_migrate!(:es)
    
    repository(:es) {

      barcelona = City.create(:name => 'Barcelona')
      benito    = Person.create(:name => 'Benito'   , :age => 11, :city => barcelona)

      madrid    = City.create(:name => 'Madrid')
      manuel    = Person.create(:name => 'Manuel'   , :age => 22, :city => madrid)
      marco     = Person.create(:name => 'Marco'    , :age => 23, :city => madrid)
    }

    DataMapper.setup(:fr, "sqlite3:///#{Dir.pwd}/fr.db")
    City.auto_migrate!(:fr)
    Person.auto_migrate!(:fr)
    
    repository(:fr) {
      paris     = City.create(:name => 'Paris')
      paulette  = Person.create(:name => 'Paulette' , :age => 34, :city => paris)
      penelope  = Person.create(:name => 'Penelope' , :age => 35, :city => paris)
    }
  end

  def test_fr_person
    repository(:fr) {
      paulette = Person.get(1)
      assert_equal 'Paulette' , paulette.name
      assert_equal 34         , paulette.age
    }
  end

  def test_fr_city
    repository(:fr) {
      paris = City.get(1)
      paulette = Person.get(1)
      penelope = Person.get(2)
      assert_equal 'Paris'              , paris.name
      assert_equal [paulette, penelope] , paris.people
    }
  end

  def test_es_person
    repository(:es) {
      manuel = Person.get(2)
      assert_equal 'Manuel' , manuel.name
      assert_equal 22       , manuel.age
    }
  end

  def test_es_city
    repository(:es) {
      madrid = City.get(2)
      manuel = Person.get(2)
      marco = Person.get(3)
      assert_equal 'Madrid'        , madrid.name
      assert_equal [manuel, marco] , madrid.people
    }
  end
end

# mungo:snippets snusnu$ ruby 1007.rb 
# Loaded suite 1007
# Started
# ....
# Finished in 0.236482 seconds.
# 
# 4 tests, 8 assertions, 0 failures, 0 errors
