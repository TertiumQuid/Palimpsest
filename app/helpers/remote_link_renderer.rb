class RemoteLinkRenderer < WillPaginate::LinkRenderer
    def prepare(collection, options, template)
        @remote = options.delete(:remote) || {}
        super
    end

    protected
    
    def page_link(page, text, attributes = {})
            options = {
                :url => url_for(page),
                :update => "table_container",
                :before => "Element.show('spinner')",
                :success => "Element.hide('spinner')",
                :method => :get
            }
        @template.link_to_remote(text, options.merge(@remote))
    end
end  