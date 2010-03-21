require "rubygems"
require "dm-core"
require "extlib/lazy_module"

class Foo
  include DataMapper::Resource
  property :id, Serial
end

# puts "nr_of_descendants = #{DataMapper::Model.descendants.count}" # <-- prints 1
# puts DataMapper::Model.descendants.inspect
# 
# remixable_lambda = lambda { property :id, Serial }
# klass = Object.const_set 'Bar', Class.new
# klass.send :include, DataMapper::Resource
# #klass.instance_eval &remixable_lambda
# 
# puts "nr_of_descendants = #{DataMapper::Model.descendants.count}" # <-- prints 1 ?????
# puts DataMapper::Model.descendants.inspect


remixable_module = LazyModule.new do
  property :id, Serial
end

klass = Object.const_set 'Bar', Class.new
klass.send :include, DataMapper::Resource
klass.send :include, remixable_module
