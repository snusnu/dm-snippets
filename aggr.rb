require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, 'mysql://localhost/saleshub_cleaner')

class ProductAssignment

  include DataMapper::Resource

  property :id,               Serial
  
  property :product_id,       Integer
  property :machine_model_id, Integer
  
  property :comment1,         Text
  property :comment2,         Text
  property :sorter,           Integer
  property :preselect,        Boolean

end


def duplicates(model, candidate_key)
  seen, dups = [], []
  model.all.each do |resource|
    key = candidate_key.map { |property| resource.send(property) }
    if seen.include?(key) && !dups.include?(key)
      yield model.all(Hash[candidate_key.zip(key)])
      dups << key
    end
    seen << key
  end
end

dupes_count, dupe_set_count, action = 0, 0, :destroy!
duplicates(ProductAssignment, [ :machine_model_id, :product_id ]) do |dupe_set|

  ids = dupe_set.map { |s| s.id }
  ids_to_destroy = (ids - [ids.max])
  resources_to_destroy = dupe_set.select { |r| ids_to_destroy.include?(r.id) }

  resources_to_destroy.each do |resource|
    dupes_count += 1
    resource.send(action) if action
  end
  dupe_set_count += 1

end

puts "Told #{dupes_count} duplicates in #{dupe_set_count} dupe sets to #{action || 'enjoy'} themselves"
