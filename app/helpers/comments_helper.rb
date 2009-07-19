module CommentsHelper
    def post_author_link(comment)
        if comment.user_id
            # Only authenticated users can see status links
            logged_in? ? link_to(h(comment.author), user_url(comment.user_id)) : h(comment.author)
        else
			comment.author or "anonymous"
        end      
    end
	
	def can_edit_comment?(comment)
		case comment.parent_type
		when "NewsArticle"
			return has_permission?("Publish News Articles")
		else
			false
		end
	end
	
	def link_to_approve_comment(comment,options={},html_options={})
		options=options.merge({
			:url => approve_comment_path(comment.id),
			:before => "Element.show('spinner')",
			:after => "$(this).remove()",
			:success => "Element.hide('spinner')",
			:method => :post
			})
			html_options=html_options.merge({:class=>"approve_link"})
		link_to_remote image_tag(image_path("/images/icons/accept.gif"), :alt => "approve", :title => "approve") << "approve", options, html_options
	end
	
	def link_to_delete_comment(comment,options={},html_options={})
		options=options.merge({
			:url => comment_path(comment.id),
			:before => "Element.show('spinner')",
			:after => "$(this).up('.comment').remove()",
			:success => "Element.hide('spinner')",
			:method => :delete, 
			:confirm => "Delete this comment? Are you sure?"
		})	
		link_to_remote image_tag(image_path("/images/icons/delete.gif"), :alt => "delete", :title => "delete") << "delete", options, html_options
	end
end