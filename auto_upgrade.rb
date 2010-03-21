require 'rubygems'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

# If the code below is refactored to use Client.property(:nationality_code) then everything works fine

class Country

  include DataMapper::Resource

  property :code, String, :key => true, :length => 2
  property :name, String, :required => true

  has n, :clients, :child_key => [:nationality]
  
end

class Client

  include DataMapper::Resource

  property :id,          Serial
  property :name,        String, :required => true
  property :nationality, String, :required => true, :default => "MY", :length => 2 

  belongs_to :nationality, 'Country', :parent_key => [:code], :child_key => [:nationality]

end

DataMapper.auto_migrate!

Country.create(:name => "Malaysia", :code => "MY")
Client.create(:name => "Joe", :nationality => "MY")

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby auto_upgrade.rb 
 ~ (0.000039) SELECT sqlite_version(*)
 ~ (0.000061) DROP TABLE IF EXISTS "countries"
 ~ (0.000012) DROP TABLE IF EXISTS "clients"
 ~ (0.000011) PRAGMA table_info("countries")
 ~ (0.000240) CREATE TABLE "countries" ("code" VARCHAR(2) NOT NULL, "name" VARCHAR(50) NOT NULL, PRIMARY KEY("code"))
 ~ (0.000008) PRAGMA table_info("clients")
 ~ (0.000178) CREATE TABLE "clients" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50) NOT NULL, "nationality" VARCHAR(2) DEFAULT 'MY' NOT NULL)
 ~ (0.000036) INSERT INTO "countries" ("code", "name") VALUES ('MY', 'Malaysia')
/Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/model/relationship.rb:369:in `nationality=': +target+ should be Country or Hash or NilClass, but was String (ArgumentError)
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/resource.rb:281:in `__send__'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/resource.rb:281:in `attributes='
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/resource.rb:277:in `each'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/resource.rb:277:in `attributes='
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/resource.rb:649:in `initialize'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/model.rb:399:in `new'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/model.rb:399:in `new'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/model.rb:626:in `_create'
	from /Users/snusnu/.rvm/gems/ree/1.8.7%saleshub/gems/dm-core-0.10.2/lib/dm-core/model.rb:413:in `create'
	from auto_upgrade!.rb:35

