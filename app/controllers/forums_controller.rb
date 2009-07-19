class ForumsController < ApplicationController
    include ApplicationHelper
	
    helper_method :can_edit_post?, :can_create_post?, :can_edit_topic?
    
    before_filter   :check_forum_authentication,    :only => [ :new, :create, :edit, :update, :destroy ]  
    after_filter    :cache_action_name,         :only => [ :new, :edit ]
	
	cache_sweeper	:forum_sweeper, :only => [:create, :update, :destroy]
	  
    def index
        set_page_title "Forums"

        @forums = Forum.all_cached
    end

    def show
		@forum = Forum.id_cached(params[:id])
        set_page_title "Forums - " + @forum.name

        @topics = @forum.forum_topics.with_recent_post.paginate :per_page => 15, :page => params[:page]
        @forum_posts = ForumPost.get_recent_forum_posts(@forum.id)
        
        # If an AJAX sort/filter/paginate request was called from the forum display...
        render(:partial => "/forum_topics/forum_topic_table", :layout => false) if request.xhr?     
    end

    def new  
        @forum = Forum.new
        set_page_title "Forums - New Forum"
    end
    
    def create
        @forum = Forum.new params[:forum]
        
       if @forum.save            
            flash[:notice] = "Forum created"
            redirect_to forum_path(@forum.id) 
        else
            render :action => session[:action_name]
        end
    end

    def edit
		@forum = Forum.find(params[:id])
        set_page_title "Forums - Edit Forum" + @forum.name
    end
    
    def update
		@forum = Forum.find(params[:id])
        if @forum.update_attributes(params[:forum])
            flash[:notice] = "Forum updated."
            redirect_to forum_path(@forum.id)
        else
            # render by action instead of session[:action_name] in order to accomodate strict nested resource routes
            render :action => :edit
        end 
    end
    
    def can_create_post?
        logged_in? or ConfigurationSetting.get_setting_to_bool( 'AllowAnonymousPosters' )
    end
    
    def can_edit_post?(post)
        post.is_author?(session[:user_id]) or belongs_to_role?('Moderator') or belongs_to_role?('Administrator')
    end
    
    def can_edit_topic?
        belongs_to_role?("Moderator") or belongs_to_role?("Administrator")
    end

    private
    
    # Wraps check_authorization in order to prevent nested child routes from being validated by the forums controller
    def check_forum_authentication
        check_authentication unless controller_name != "forums"
    end
end
