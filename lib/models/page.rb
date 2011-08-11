class Page
  include DataMapper::Resource

  property :id, Serial
  property :title, String, length: 255, required: true
  property :content, String, length: 2**32-1, required: true
  property :slug, String, length: 255

  before :save do
    attribute_set :slug, attribute_get(:title).to_url
  end

  def self.url_for(id)
    first(:id => id).slug
  end

  def url
    attribute_get :slug
  end

  def to_html
    @html ||= RDiscount.new(self, :smart).to_html
  end
end
