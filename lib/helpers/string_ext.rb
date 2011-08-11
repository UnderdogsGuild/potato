class String
  ##
  # Convert a string to html with RDiscount
  #
  # @param bare Boolean Omit wrapping paragraph tags in output
  def to_html(bare = false)
    return nil if self.nil? or bare.nil?
    rd = RDiscount.new(self, :generate_toc, :smart)
    html = rd.to_html
    html.gsub! "{:toc}", rd.toc_content if rd.generate_toc
    html.gsub!(/^<p>(.*)<\/p>$/, '\1') if bare
    html
  end
end
