before :all do
  module ::Blog
    class Article
      include DataMapper::Resource

      property :id,      Serial
      property :title,   String, :nullable => false
      property :content, Text
      property :subtitle, String
      property :author,  String, :nullable => false

      belongs_to :original, self, :nullable => true
      has n, :revisions, self, :child_key => [ :original_id ]
      has 1, :previous,  self, :child_key => [ :original_id ], :order => [ :id.desc ]
    end
  end

  @article_model = Blog::Article
end

it 'should return the last statement in the transaction block' do
  @user_model.transaction { 1 }.should == 1
end

property :taken_at, Time, :default => lambda { |resource, property| Time.now }