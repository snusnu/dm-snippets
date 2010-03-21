module ParameterSanitization

  def self.included(host)
    host.extend(ClassMethods)
    host.send(:include, InstanceMethods)
  end

  module ClassMethods
    attr_reader :resource, :properties_to_sanitize
    def sanitize_resource_params(resource, *properties)
      @resource               = resource
      @properties_to_sanitize = properties
    end
  end

  module InstanceMethods

    # overwrite params accessor
    def params
      @sanitized_params ||= sanitize_resource_params(super)
    end

  private

    def resource
      @resource ||= Object.const_get(self.class.resource)
    end

    def default_types_to_sanitize
      [ Integer, Float, BigDecimal ]
    end

    def properties_to_sanitize
      self.class.properties_to_sanitize
    end

    def sanitize_resource_params(orig_params)
      p = {}
      orig_params.each do |name, value|
        p[name] = needs_param_sanitization?(resource, name, value) ? nil : orig_params[name]
      end
      p
    end

    def needs_param_sanitization?(resource, param_name, param_value)
      return false unless resource.properties.named?(param_name.to_sym)
      default_types_to_sanitize.include?(resource.properties[param_name].type) &&
       # resource.properties[param_name].type == Integer     ||
       # resource.properties[param_name].type == Float       ||
       # resource.properties[param_name].type == BigDecimal  ||
       properties_to_sanitize.include?(param_name)         &&
       resource.properties[param_name].allow_nil?          &&
       param_value.blank?
    end

  end
end


require 'rubygems'
require 'dm-core'
require 'spec'

shared_examples_for 'datamapper parameter sanitization' do
  it 'should convert blank strings into nil for properties of type Integer' do
    PeopleController.new.params[:age].should be_nil
  end
  it 'should convert blank strings into nil for properties of type Float' do
    PeopleController.new.params[:weight].should be_nil
  end
  it 'should convert blank strings into nil for properties of type BigDecimal' do
    PeopleController.new.params[:cash].should be_nil
  end
end

describe 'ParameterSanitization' do
  before(:all) do
    class Person
      include DataMapper::Resource
      property :id,     Serial
      property :age,    Integer
      property :weigth, Float
      property :cash,   BigDecimal
      property :bio,    Text
    end
    class Controller
      def params
        { :age => '', :weigth => '', :cash => '', :bio => '' }
      end
    end
  end
  describe 'without custom properties to sanitize' do
    before(:each) do
      class PeopleController < Controller
        include ParameterSanitization
        sanitize_resource_params 'Person'
      end
    end
    it_should_behave_like 'datamapper parameter sanitization'
    it 'should not convert blank strings into nil for properties that are not of either Integer, Float or BigDecimal' do
      PeopleController.new.params[:bio].should == ''
    end
  end
  describe 'with custom properties to sanitize' do
    before(:each) do
      class PeopleController < Controller
        include ParameterSanitization
        sanitize_resource_params 'Person', :bio
      end
    end
    it_should_behave_like 'datamapper parameter sanitization'
    it 'should convert blank strings into nil for custom properties specified with .sanitize_resource_params' do
      PeopleController.new.params[:bio].should be_nil
    end
  end
end

__END__

ree-1.8.7-2010.01 mungo:snippets snusnu$ spec -cfs dm_parameter_sanitization.rb 

ParameterSanitization without custom properties to sanitize
- should convert blank strings into nil for properties of type Integer
- should convert blank strings into nil for properties of type Float
- should convert blank strings into nil for properties of type BigDecimal
- should not convert blank strings into nil for properties that are not of either Integer, Float or BigDecimal

ParameterSanitization with custom properties to sanitize
- should convert blank strings into nil for properties of type Integer
- should convert blank strings into nil for properties of type Float
- should convert blank strings into nil for properties of type BigDecimal
- should convert blank strings into nil for custom properties specified with .sanitize_resource_params

Finished in 0.010317 seconds

8 examples, 0 failures


