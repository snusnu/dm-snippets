require "rubygems"
require "dm-core"
require "dm-validations"

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")


class User
  include DataMapper::Resource

  property :id, Serial

  has 0..n, :recommendations
  has 0..n, :recommendees,   :through => :recommendations, :model => "User", :target_key => [:user_id]
  has 0..n, :recommended_by, :through => :recommendations, :model => "User", :target_key => [:recommendee_id], :via => :user

end

class Recommendation
  include DataMapper::Resource

  property  :user_id,        Integer, :key => true
  property  :recommendee_id, Integer, :key => true

  belongs_to :user
  belongs_to :recommendee, 'User', :source_key => [:recommendee_id]
  
  validates_with_block :recommendee_id do
    if @recommendee_id == @user_id
      [false, "A user can not recommend himself"]
    else
      true
    end
  end
end

DataMapper.auto_migrate!

u = User.create

u = User.get(u.id)
u.recommendations
u.recommendations.create(:recommendee => u)
u.valid?
u.all_valid?
rec = u.recommendations.first

puts rec.instance_variables.map { |ivar| "ivar name: #{ivar} ivar: #{rec.t(ivar).inspect}" }.join("\n")


# mungo:snippets snusnu$ ruby balint.rb 
#  ~ (0.000349) SELECT sqlite_version(*)
#  ~ (0.000393) DROP TABLE IF EXISTS "users"
#  ~ (0.000066) DROP TABLE IF EXISTS "recommendations"
#  ~ (0.000061) PRAGMA table_info("users")
#  ~ (0.001083) CREATE TABLE "users" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
#  ~ (0.000027) PRAGMA table_info("recommendations")
#  ~ (0.000601) CREATE TABLE "recommendations" ("user_id" INTEGER NOT NULL, "recommendee_id" INTEGER NOT NULL, PRIMARY KEY("user_id", "recommendee_id"))
#  ~ (0.000096) INSERT INTO "users" DEFAULT VALUES
#  ~ (0.000065) SELECT "id" FROM "users" WHERE "id" = 1
# /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:293:in `respond_to?': stack level too deep (SystemStackError)
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/collection.rb:908:in `respond_to?'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:108:in `recursive_valid?'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:104:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:104:in `recursive_valid?'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:111:in `recursive_valid?'
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:109:in `recursive_valid?'
#    ... 4980 levels...
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:104:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:104:in `recursive_valid?'
#   from /opt/local/lib/ruby/gems/1.8/gems/dm-validations-0.10.0/lib/dm-validations.rb:97:in `all_valid?'
#   from balint.rb:46
# mungo:snippets snusnu$ 
