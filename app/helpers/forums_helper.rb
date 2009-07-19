module ForumsHelper
    def forum_breadcrumbs
        breadcrumbs = "<h2 class='left'>"
        if params[:id]
            forum = @forum or @forum_topic.forum or @forum_post.forum.forum_topic
            
            breadcrumbs << link_to("Forums", forums_path, :alt => "Back to forum index")
            
            breadcrumbs << " > " << link_to(h(forum.name), forum_path(forum.id), :alt => "Back to #{h(forum.name)}")
            
            breadcrumbs << " > " << link_to(h(@forum_topic.title), forum_forum_topic_path(forum.id,@forum_topic.id), :alt => "Back to #{h(@forum_topic.title)}") if @forum_topic
        else
            breadcrumbs << "Forums" 
        end
        breadcrumbs << "</h2>"
    end
end

