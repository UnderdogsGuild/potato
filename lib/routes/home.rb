class Application < Sinatra::Base

  ##
  # The news index, cheaply aliased to the root path.
  ['/', '/news/?']. each do |r|
    get r do
      @entries = NewsEntry.all_published
      haml :'news/index'
    end
  end

  ##
  # Display a full page for a certain entry
  get '/news/:slug/?' do
    @entry = NewsEntry.first :slug => params[:slug]
    throw :halt, [404, "Not found"] unless @entry
    haml :'news/show'
  end

  ##
  # Generic semi-static pages
  get '/:page/?' do
    @page = Page.first(:slug => params[:page])
    throw :halt, [404, "Not found"] unless @page
    haml :'pages/show'
  end

end
