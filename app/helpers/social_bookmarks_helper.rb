module SocialBookmarksHelper
    def footer_bookmarks
        title = ConfigurationSetting.get_setting( 'SiteTitle' )
        url = u(request.protocol << request.host_with_port << "/" << ConfigurationSetting.get_setting( 'SiteURL' ))
        
        html = "<div class='bookmarklets'>Bookmarks: "
        SocialBookmark.with_active.with_ordered.all.each do |bookmarklet|
            target = bookmarklet.url.gsub!(/\{\{U\}\}/, url).gsub!(/\{\{T\}\}/, title)
            html << link_to(image_tag(bookmarklet.icon.url), target)
        end
        html << '</div>'
    end
end