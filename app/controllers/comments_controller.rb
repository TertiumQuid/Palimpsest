class CommentsController < ApplicationController
    include ApplicationHelper, CommentsHelper
	
	before_filter   :prepare_parent,			:only => [ :create ]
    before_filter   :prepare_comment,			:only => [ :approve, :destroy ]
	
    before_filter   :check_can_edit_comment,	:only => [ :approve, :destroy ]
	
    def create    		
        @comment = get_comment_with_defaults(params)
		
        # We endure some semantic coupling to act as the glue between REST, AJAX, and RJS, and presume 
        # that certain DOM elements will be present and require updating in response to the save action
        render :update do |page|
            if @comment.save
                flash[:notice] = (@parent.moderate_comments ? "Comment submitted, but must be approved by a moderator before it appears." : "Comment posted.")
                page.replace_html :flash_banner, :partial => "layouts/flash_banner"
                flash.delete(:notice)
                
				# Only refresh the comments table if the new comment doesn't require moderation
				unless @parent.moderate_comments
					@parent.reload
					@comments = @parent.comments
					page.replace_html :table_container, :partial => "comments/table"
				end
                page[:comment_form].reset
            else
                page.replace_html :form_errors, error_messages_for(:comment)
            end
        end
    end
	
    def destroy
        @comment.destroy
		
		render :update do |page|
			flash[:notice] = "Comment removed."
			page.replace_html :flash_banner, :partial => "layouts/flash_banner"
			flash.delete(:notice)
		end
    end
	
	# Approves a moderated comment for public viewing
	def approve
		@comment.update_attribute(:is_approved,'true')
		
		render :update do |page|
			flash[:notice] = "Comment approved."
			page.replace_html :flash_banner, :partial => "layouts/flash_banner"
			flash.delete(:notice)
		end
	end
    
    private 

    # Create a new comment scoped to the current parent, with user session defaults. It's really up to the controller
    # how to compose this info, which is why this logic is placed here and not in the Comment model.
    def get_comment_with_defaults(params)
        comment = @parent.comments.new(params[:comment])
        comment.ip_address = request.remote_ip
		
        # Automatically populate comment data if existing user
        if logged_in?
            comment.user = current_user
            comment.author = comment.user.username
            comment.email = comment.user.email
            comment.website_url = comment.user.website_url
        end
        return comment
    end
	
	# Sets the requested comment instance
	def prepare_comment
		@comment = Comment.find_comment(params[:id])
	end
	
	# Sets the requested comment instance's parent 
	def prepare_parent
		case params[:parent_type]
		when "NewsArticle"
			polymorph_parent NewsArticle.find(params[:parent_id])
		end		
	end
	
    def check_can_edit_comment
		unless can_edit_comment? @comment
			flash[:warning] = "You do not have permission to modify this comment."
			redirect_to :back
			return false
		end
    end
end