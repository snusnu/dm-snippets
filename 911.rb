require 'rubygems'
require 'dm-core'
require 'dm-validations'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :type, Discriminator
end

class Textbug < Element
  property :content, Text
  validates_present :content
end

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/content.db")
DataMapper.auto_upgrade!

box = Textbug.create({:content => 'hello'})
Element.all.each do |e|
  puts e.content
end

# mungo:snippets snusnu$ ruby 911.rb 
# /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:741:in `assert_valid_fields': +options[:field]+ entry :content does not map to a property in Element (ArgumentError)
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:732:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:732:in `assert_valid_fields'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:708:in `assert_valid_options'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:706:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:706:in `assert_valid_options'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:648:in `initialize'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:354:in `update'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/query.rb:370:in `merge'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/collection.rb:73:in `reload'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:817:in `reload_attributes'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/resource.rb:802:in `lazy_load'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/property.rb:660:in `send'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/property.rb:660:in `lazy_load'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/property.rb:539:in `get'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/model/property.rb:206:in `content'
#   from 911.rb:22
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from 911.rb:21

