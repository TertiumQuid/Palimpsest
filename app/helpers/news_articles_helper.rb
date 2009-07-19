module NewsArticlesHelper

    def previous_month_link(date=Time.now)
        link_to "&lt;&lt; " << date.advance(:months => -1).strftime("%b"), 
                news_archives_path(date.advance(:months=>-1).year,date.advance(:months=>-1).month),
                :class => "left"
    end
    
    def next_month_link(date=Time.now)
        link_to date.advance(:months => 1).strftime("%b") << " &gt;&gt;", 
            news_archives_path(date.advance(:months=>1).year,date.advance(:months=>1).month),
            :class => "right"
    end
    
    def month_and_year_select(date=Time.now)
        "<table cellpadding=0 cellspacing=0 width=95%><tr><td>" + 
            select_month(date.month,{:use_short_month => true},{:onchange => "window.location='/news_archives/" + @year.to_s + "/' + this.options[this.selectedIndex].value;"}) + "</td><td>" + 
            select_year(date.year, {:start_year => date.year-10, :end_year => Time.now.year+3},{:onchange => "window.location='/news_archives/' + this.options[this.selectedIndex].value + '/" + @month.to_s + "';"}) + "</td></tr></table>"
    end
    
    def wall_calendar_page(news_article)
        html_block = "<div class='calendar_cell'>"
        html_block << "<div class='calendar_cell_month'>"
        html_block << link_to(news_article.created_at.strftime('%b'), news_archives_path(news_article.created_at.year,news_article.created_at.month))
        html_block << "</div>"
        html_block << "<div class='calendar_cell_day'>"
        html_block << link_to(news_article.created_at.strftime('%d'),news_archives_path(news_article.created_at.year,news_article.created_at.month,news_article.created_at.day)) << "<br />"
        html_block << link_to(news_article.created_at.strftime('%Y'), news_archives_path(news_article.created_at.year), :class => "calendar_cell_year")
        html_block << "</div></div>"
        
        return html_block
    end
    
    # Links to all tags for a given article
    def footer_tags_for(news_article)
        if news_article.tag_list.size > 0
           "<ul class='link_tag'>#{news_article.tag_list.map {|t| "<li>#{link_to(t,news_tag_path(t))}</li>"}}</ul>"
        else
           "<span>untagged article</span>"
        end
    end
    
    # Links to comments for an article
    def footer_comments_for(news_article)
         html_block = "<span class='comments_link right'>"
         html_block << link_to(image_tag("icons/comment.gif",:class=>"comments_link") << " " << pluralize(news_article.approved_comments_count, "comment"), 
                               news_article_path(news_article.id) << "#table_container")
                                  
         html_block << "</span>"
        
         return html_block
    end
    
    # Links to the user page of an article's author
    def author_link(news_article,full_date=false)
         html_block = "<div class='author_link right'>Posted by "
         html_block << link_to(h(news_article.user.display_name), user_path(news_article.user_id), :style => "color:rgb(100,149,237);")
         html_block << " on <span style='color:rgb(60,60,60);'>#{news_article.created_at.strftime('%b %d, %Y')}</span>" if full_date
         html_block << " at #{news_article.created_at.strftime('%I:%M %p')}"
         html_block << "</div>"
        
         return html_block
    end
    
    # Links paragraph to article, using the "summary" field if it exists, or else by truncating the "body"
    def article_description(news_article)
        if news_article.summary.blank? 
            link = truncate(news_article.body, 255, "...") 
        else
            link = h(news_article.summary)
        end
        
        return strip_tags(link) << " " << link_to(" (read more)", news_article_path(news_article.id))
    end
    
    def category_link(news_article,css_class="")
        return if news_article.news_article_category_id.blank?
          
        html_block = "<div class='news_category_title #{css_class}'>Category: "
        html_block << link_to(h(news_article.news_article_category.title), news_category_path(h(news_article.news_article_category.title)))
        html_block << "</div>" 
        
        return html_block
    end
    
    def year_month_link(date)
        link_to(date.strftime("%Y %B") << " (" << NewsArticle.month_year_count(date).to_s << ")", news_archives_path(date.year,date.month))
    end
    
    def fields_for_file_attachment(article, &block)
        prefix = article.new_record? ? 'new' : 'extant'
        fields_for("news_article[#{prefix}_file_attachment_attributes][]", article, &block)
    end

end
