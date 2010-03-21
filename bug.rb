require 'rubygems'
require 'dm-core'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Post

  include DataMapper::Resource

  property :id,            Serial

  has n, :post_tags
  has n, :tags, :through => :post_tags

  def tag_list
    tags.all.map { |t| t.name }.join(', ')
  end

  def tag_list=(list)
    list.each do |tag|
      new_tag = Tag.first_or_create(:name => tag)
      tags << new_tag
    end
  end

end

class PostTag

  include DataMapper::Resource

  property :post_id, Integer, :key => true
  property :tag_id,  Integer, :key => true

  belongs_to :post
  belongs_to :tag

end

class Tag

  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :nullable => false, :unique => true, :unique_index => true


  has n, :post_tags

  has n, :posts,
    :through => :post_tags

end

DataMapper.auto_migrate!

p '-'*80

p1 = Post.create(:tag_list => ['foo','bar'])
p2 = Post.create(:tag_list => ['foo','bar'])

puts "WORKS"

puts "#{p1.tags.inspect}" # correctly prints both tags
puts "#{p2.tags.inspect}" # correctly prints both tags

puts "FAILS"

Post.all.each_with_index do |p, idx|
  puts "idx = #{idx}, tags = #{p.tags.inspect}" # prints only the first tag
end