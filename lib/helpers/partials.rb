module PartialHelpers
  def partial(template,locals=nil)
    # Makes for easy list filtering
    return nil if template.blank?

    if template.is_a?(String) || template.is_a?(Symbol)
      template = "_#{template.to_s}".to_sym
    else
      locals = template
      name = template.is_a?(Array) ? template.first : template
      name = name.class.to_s.to_const_path
      components = name.split "/"
      item = components[-1]
      components[-1] = "_#{components[-1]}"
      template = components.join("/").to_sym

      #template=template.is_a?(Array) ?
        #('_' + template.first.class.to_s.downcase).to_sym :
        #('_' + template.class.to_s.downcase).to_sym
    end
    if locals.is_a?(Hash)
      haml(template,{:layout => false},locals)      
    elsif locals
      locals=[locals] unless locals.respond_to? :inject
      locals.inject [] do |output,element|
        output << haml(template, {:layout=>false}, {item.to_sym => element}) unless element.blank?
      end.join("\n")
    else 
      haml template, {:layout => false}
    end
  end
end

module Helpers
  module RenderHelpers
    ##
    # Partials implementation which includes collections support.
    # Copied from Padrino.
    #
    # ==== Examples
    #
    #   partial 'photo/item', :object => @photo
    #   partial 'photo/item', :collection => @photos
    #   partial 'photo/item', :locals => { :foo => :bar }
    #   partial 'photo/item', :engine => :erb
    #
    def partial(template, options={})
      options.reverse_merge!(:locals => {}, :layout => false)
      path = template.to_s.split(File::SEPARATOR)
      object_name = path[-1].to_sym
      path[-1] = "_#{path[-1]}"
      explicit_engine = options.delete(:engine)
      template_path = File.join(path).to_sym
      raise 'Partial collection specified but is nil' if options.has_key?(:collection) && options[:collection].nil?
      if collection = options.delete(:collection)
        options.delete(:object)
        counter = 0
        collection.map { |member|
          counter += 1
          options[:locals].merge!(object_name => member, "#{object_name}_counter".to_sym => counter)
          render(explicit_engine, template_path, options.dup)
        }.join("\n")
      else
        if member = options.delete(:object)
          options[:locals].merge!(object_name => member)
        end
        render(explicit_engine, template_path, options.dup)
      end
    end
    alias :render_partial :partial
  end # RenderHelpers
end # Helpers

# Using my own implementation for now. Padrino works differently.
Application.helpers PartialHelpers
