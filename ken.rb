require 'rubygems'

require 'pathname'
require 'extlib'
require 'haml'


# helper
def render_ken_resource(ken_resource)
  Ken::Render::Factory.create_renderer(ken_resource).render
end


module Ken
  module Render
    
    
    class RendererNotFoundError < RuntimeError; end
    class AmbiguousResourceError < RuntimeError; end
    
    
    def self.descendants
      @descendants ||= []
    end
    
    # customize
    def self.template_root
      if Object.const_defined?('Merb')
        Pathname(Merb.root) + 'lib/renderers'
      elsif Object.const_defined?('Rails')
        Pathname(Rails.root) + 'lib/renderers'
      else
        raise "You need to specify a template root"
      end
    end
    
    module Mixin
      
      def self.included(base)
        extend ClassMethods
        Ken::Render.descendants << base
        attr_reader :ken_resource
      end
      
      def render
        Haml::Engine.new(template).render(self)
      end
      
      
      # customize this
      
      def initialize(ken_resource)
        @ken_resource = ken_resource
      end
      
      def template
        File.read(template_path + template_name)
      end
      
      def template_path
        Pathname(Ken::Render.template_root).expand_path
      end
      
      def template_name
        "#{Extlib::Inflection.snake_case(Extlib::Inflection.demodulize(self.class.name))}.haml"
      end
      
      module ClassMethods
        
        def matches?(ken_resource)
          raise NotImplementedError
        end
        
      end
      
    end
    
    class Factory
      
      def self.create_renderer(ken_resource)
        
        renderers = Ken::Render.descendants.select do |renderer|
          renderer.matches?(ken_resource)
        end
        
        raise Ken::Render::RendererNotFoundError  if renderers.size == 0
        raise Ken::Render::AmbiguousResourceError if renderers.size > 1
        
        renderers.first.new(ken_resource)
        
      end
      
    end
    
  end
end


# should go to lib/ken/renderers/album_renderer.rb
class AlbumRenderer
  
  include Ken::Render::Mixin
  
  def self.matches?(ken_resource)
    ken_resource.type.id == '/music/artist/album'
  end
  
  def render_bindings
    @album = ken_resource
  end
  
end
