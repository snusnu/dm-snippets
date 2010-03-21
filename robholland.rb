class Campaign

  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false

  has n, :urls, :through => :campaign_urls

end

class Url

  include DataMapper::Resource

  property :id,  Serial

  property :url, String,
    :nullable => false
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