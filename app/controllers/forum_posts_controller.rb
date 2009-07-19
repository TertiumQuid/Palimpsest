class ForumPostsController < ForumsController
    include ApplicationHelper, ForumsHelper

    before_filter   :check_can_edit_post,      :only => [ :edit, :update, :destroy ]
    before_filter   :check_can_create_post,    :only => [ :new, :create ]
    before_filter   :check_negative_captcha,   :only => [ :create ]
	
	cache_sweeper	:forum_sweeper, :only => [:create, :update, :destroy]

    def show_user_posts
        @user = User.find(params[:user_id])
        @forum_posts = @user.forum_posts.paginate :per_page => 10, :page => params[:page]

        set_page_title "Forums - " + @user.display_name + "'s Posts"
    end

    def create
        @forum_topic = ForumTopic.find(params[:forum_topic_id])
        @forum_post = get_post_with_defaults(params)

        # We endure some semantic coupling to act as the glue between REST, AJAX, and RJS, and presume
        # that certain DOM elements will be present and require updating in response to the save action
        render :update do |page|
            if @forum_post.save
                flash[:notice] = "Replied to '" + @forum_topic.title + "'"
                page.replace_html :flash_banner, :partial => "layouts/flash_banner"
                flash.delete(:notice)

                @forum_topic_posts = @forum_topic.reload.forum_posts.paginate :per_page => 10, :page => params[:page]
                page.replace_html :table_container, :partial => "forum_posts/table"
                page[:forum_post_form].reset
            else
                page.replace_html :form_errors, error_messages_for(:forum_post)
            end
        end
    end

    def edit
        @forum = Forum.id_cached(@forum_topic.forum_id)

        set_page_title "Forums - Edit " + @forum_post.subject
    end

    def update
        if @forum_post.update_attributes(params[:forum_post])
            flash[:notice] = "Post updated."
            redirect_to forum_forum_topic_path(@forum_topic.forum_id,@forum_topic.id)
        else
            # render by action instead of session[:action_name] in order to accomodate strict nested resource routes
            render :action => :edit
        end
    end

    def destroy
        topic = ForumTopic.find(params[:forum_topic_id])
        post = topic.forum_posts.find(params[:id])
        post.destroy

        flash[:notice] = "Post deleted"
        redirect_to forum_forum_topic_path(topic.forum_id,topic.id)
    end

    private

    def check_can_edit_post
        @forum_topic = ForumTopic.find(params[:forum_topic_id])
        @forum_post = @forum_topic.forum_posts.find(params[:id])
        @forum = Forum.id_cached(@forum_topic.forum_id)

        unless can_edit_post?(@forum_post)
            flash[:warning] = "You do not have permission to edit this post."
            redirect_to :back
            return false
        end
    end

    def check_can_create_post
        @forum_topic = ForumTopic.find(params[:forum_topic_id])

        unless (can_create_post? and not @forum_topic.locked)
            flash[:warning] = "You do not have permission to create posts."
            redirect_to :back
            return false
        end
    end

    private

    # Create a new post scoped to the current topic, with user session defaults. It's really up to the controller
    # how to compose this info, which is why this logic is placed here and not in the ForumPost model.
    def get_post_with_defaults(params)
        post = @forum_topic.forum_posts.build params[:forum_post]

        # Automatically populate comment data if existing user
        if logged_in?
            post.user = current_user
            post.username = current_user.username
            post.user_id = current_user.id
        end
        return post
    end
end
