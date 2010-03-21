require 'rubygems'
require 'dm-core'
require 'dm-timestamps'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3:memory:')

class Photo
  include DataMapper::Resource
  property :id, Serial
  has n, :category_photos, :order => [ :created_at.asc ]
  has n, :categories, :through => :category_photos
end

class CategoryPhoto
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  belongs_to :photo
  belongs_to :category
end

class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String
end

DataMapper.auto_migrate!

photo = Photo.create
photo.categories.create(:name => 'first')
sleep 1
photo.categories.create(:name => 'second')
sleep 1
photo.categories.create(:name => 'third')
sleep 1

photo.categories.each_with_index do |c, idx|
  puts "#{idx}: #{c.name}"
end

CategoryPhoto.all(:order => [:created_at.asc]).each_with_index do |cp, idx|
  puts "#{idx}: #{cp.category.name} (#{cp.created_at})"
end

CategoryPhoto.all(:order => [:created_at.desc]).each_with_index do |cp, idx|
  puts "#{idx}: #{cp.category.name} (#{cp.created_at})"
end

__END__