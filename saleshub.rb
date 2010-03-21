require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/attribute_accessors'
module UrlFor
  extend ActiveSupport::Concern

  included do
    ActionController::Routing::Routes.install_helpers(self)

    # Including in a class uses an inheritable hash. Modules get a plain hash.
    if respond_to?(:class_attribute)
      class_attribute :default_url_options
    else
      mattr_accessor :default_url_options
    end

    self.default_url_options = {}
  end
end