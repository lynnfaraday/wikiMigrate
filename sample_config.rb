class WikiConfig
  attr_accessor :mediawiki_url, :mediawiki_user, :mediawiki_password, :wikidot_api_key, :wikidot_site
  
  def initialize
    @mediawiki_url = 'http://YOURMEDIAWIKIURL/api.php'
    @mediawiki_user = 'USER'
    @mediawiki_password = 'PASSWORD'
    
    @wikidot_api_key = "API KEY"
    @wikidot_site = "SITE NICKNAME - just the first part before wikidot.com"
  end
end
