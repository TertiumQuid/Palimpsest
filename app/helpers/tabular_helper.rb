module TabularHelper
    # Returns a <th> tag containing a remote link for a sorted table column. Pass the symbol parameter if there are multiple onscreen tables.
    def sorted_th_link(text,param,symbol=:sort,is_default=false)
        key = param
        key += "_desc" if params[symbol] == param or (params[symbol].blank? and is_default)
        options = {
            :url => {:params => params.merge({symbol => key, :page => nil})},
            :update => "table_container",
            :before => "Element.show('spinner')",
            :success => "Element.hide('spinner')",
            :method => :get
        }
        html_options = {
          :title => "Sort by this field",
          :href => url_for(:action => 'list', :params => params.merge({symbol => key, :page => nil}))
        }
        css_class = "sortup" if params[symbol] == param
        css_class = "sortdown" if params[symbol] == param + "_desc"
        
        arrow = image_tag("icons/bullet_arrow_up.gif") if params[symbol] == param
        arrow = image_tag("icons/bullet_arrow_down.gif") if params[symbol] == param + "_desc"
        arrow ||= image_tag("icons/bullet_arrow_up.gif") if params[symbol].blank? and is_default
      
        "<th class='#{css_class}'>#{link_to_remote(text << (arrow||=""), options, html_options)}</th>"
    end
    
    def alphabet_link(letter,options={},html_options={})
        options.merge({
            :update => "table_container",
            :before => "Element.show('spinner')",
            :success => "Element.hide('spinner')",
            :method => :get
        })
        html_options.merge({ :title => "View by " << letter})
        link_to_remote letter, options, html_options
    end
end