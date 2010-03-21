require 'rubygems'
require 'dm-core'
require 'dm-validations'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Campaign

  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false

  has n, :campaign_urls

  
  # The following 2 relationship definitions are wrong on purpose.
  # However, dm doesn't complain. Also, if you change them to
  # :through => :campaign_urls, the generated sql looks the same and doesn't
  # behave right either. An alternative that actually works, is to explicitly
  # provide 2 scoped 1:n relationships and 2 m:m relationships that go :through
  # those, but I think the syntax below (without the obviously wrong value for
  # :through) reads nicer and should work too.

  has n, :primary_urls,    'Url',
    :through => :campaign_primary_urls,    # <-- NOTE that this relationship doesn't exist
    :via => :url,
    'campaign_urls.competitor' => false

  has n, :competitor_urls, 'Url',
    :through => :campaign_competitor_urls, # <-- NOTE that this relationship doesn't exist
    :via => :url,
    'campaign_urls.competitor' => true

end

class Url

  include DataMapper::Resource

  property :id,  Serial

  property :url, String,
    :nullable => false,
    :length   => 255,
    :format   => /(^$)|(^(http| https):\/\/[a-z0-9\-\.]+([\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(([0-9]{1,5})? \/.*)?$)/ix
  
  validates_is_unique :url

  # dunno if you need that
  has n, :campaigns, :through => :campaign_urls

end

class CampaignUrl

  include DataMapper::Resource

  property :id,          Serial
  
  # these 2 property definitions aren't strictly
  # necessary because they are implicitly established
  # by the 2 calls to belongs_to belog
  property :url_id,      Integer, :nullable => false
  property :campaign_id, Integer, :nullable => false
  
  property :competitor,  Boolean, :nullable => false, :default => false


  belongs_to :url
  belongs_to :campaign

end

DataMapper.auto_migrate!

campaign = Campaign.create(
  :name            => 'orm',
  :primary_urls    => [ Url.new(:url => 'http://datamapper.org'  ) ],
  :competitor_urls => [ Url.new(:url => 'http://activerecord.org') ]
)

puts "primary_urls    = #{Campaign.first.primary_urls.inspect}"
puts "competitor_urls = #{Campaign.first.competitor_urls.inspect}"

# mungo:snippets snusnu$ ruby kung_fu_mike.rb 
#  ~ (0.000154) SELECT sqlite_version(*)
#  ~ (0.000100) DROP TABLE IF EXISTS "campaigns"
#  ~ (0.000017) DROP TABLE IF EXISTS "urls"
#  ~ (0.000015) DROP TABLE IF EXISTS "campaign_urls"
#  ~ (0.000025) PRAGMA table_info("campaigns")
#  ~ (0.000371) CREATE TABLE "campaigns" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50) NOT NULL)
#  ~ (0.000010) PRAGMA table_info("urls")
#  ~ (0.000111) CREATE TABLE "urls" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "url" VARCHAR(255) NOT NULL)
#  ~ (0.000010) PRAGMA table_info("campaign_urls")
#  ~ (0.000126) CREATE TABLE "campaign_urls" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "url_id" INTEGER NOT NULL, "campaign_id" INTEGER NOT NULL, "competitor" BOOLEAN DEFAULT 'f' NOT NULL)
#  ~ (0.000060) INSERT INTO "campaigns" ("name") VALUES ('orm')
#  ~ (0.000044) SELECT "id" FROM "urls" WHERE "url" = 'http://activerecord.org' ORDER BY "id" LIMIT 1
#  ~ (0.000040) INSERT INTO "urls" ("url") VALUES ('http://activerecord.org')
#  ~ (0.000039) SELECT "id", "url_id", "campaign_id", "competitor" FROM "campaign_urls" WHERE "campaign_id" = 1 AND "url_id" = 1 ORDER BY "id" LIMIT 1
#  ~ (0.000047) INSERT INTO "campaign_urls" ("url_id", "campaign_id", "competitor") VALUES (1, 1, 'f')
#  ~ (0.000030) SELECT "id" FROM "urls" WHERE "url" = 'http://datamapper.org' ORDER BY "id" LIMIT 1
#  ~ (0.000041) INSERT INTO "urls" ("url") VALUES ('http://datamapper.org')
#  ~ (0.000038) SELECT "id", "url_id", "campaign_id", "competitor" FROM "campaign_urls" WHERE "campaign_id" = 1 AND "url_id" = 2 ORDER BY "id" LIMIT 1
#  ~ (0.000046) INSERT INTO "campaign_urls" ("url_id", "campaign_id", "competitor") VALUES (2, 1, 'f')
#  ~ (0.000025) SELECT "id", "name" FROM "campaigns" ORDER BY "id" LIMIT 1
#  ~ (0.000074) SELECT "urls"."id", "urls"."url" FROM "urls" INNER JOIN "campaigns" ON "campaign_urls"."campaign_id" = "campaigns"."id" INNER JOIN "campaign_urls" ON "urls"."id" = "campaign_urls"."url_id" WHERE "campaign_urls"."competitor" = 'f' AND "campaign_urls"."campaign_id" = 1 GROUP BY "urls"."id", "urls"."url" ORDER BY "urls"."id"
# primary_urls    = [#<Url @id=1 @url="http://activerecord.org">, #<Url @id=2 @url="http://datamapper.org">]
#  ~ (0.000026) SELECT "id", "name" FROM "campaigns" ORDER BY "id" LIMIT 1
#  ~ (0.000067) SELECT "urls"."id", "urls"."url" FROM "urls" INNER JOIN "campaigns" ON "campaign_urls"."campaign_id" = "campaigns"."id" INNER JOIN "campaign_urls" ON "urls"."id" = "campaign_urls"."url_id" WHERE "campaign_urls"."competitor" = 't' AND "campaign_urls"."campaign_id" = 1 GROUP BY "urls"."id", "urls"."url" ORDER BY "urls"."id"
# competitor_urls = []

