class NewsEntry
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :length => 255, :required => true
  property :tagline, String, :length => 255
  property :content, String, :length => 2**32-1, :required => true
  property :publish_on, Time, :default => ->(m,r){ Time.now }
  property :published, Boolean, :default => false
  property :slug, String, :length => 255

  before :save do
    attribute_set :slug, attribute_get(:title).to_url
  end

  def self.all_published
    all(:published => true, :publish_on.lte => Time.now)
  end

  def url
    "/noticias/#{attribute_get(:publish_on).
                 strftime("%Y-%m-%d")}/#{attribute_get(:id)}-#{attribute_get(:slug)}"
  end

  def published_on
    attribute_get :publish_on
  end
end
