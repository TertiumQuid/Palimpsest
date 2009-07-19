class ForumTopicsController < ForumsController
    include ApplicationHelper, ForumsHelper

    before_filter   :prepare_forum
    before_filter   :prepare_forum_topic,       :only => [ :show, :edit, :update, :destroy ]
    
    before_filter   :check_can_edit_topic,      :only => [ :edit, :update, :destroy ]
    before_filter   :check_can_create_post,     :only => [ :new, :create ]
    before_filter   :check_negative_captcha,    :only => [ :create, :update ]
    
    after_filter    :cache_action_name,         :only => [ :show, :new, :edit ]
	
	cache_sweeper	:forum_sweeper, :only => [:create, :update, :destroy]

    def show
        # Get scoped forum, topic, and posts
        @forum_topic_posts = @forum_topic.forum_posts.paginate :per_page => 10, :page => params[:page]
        
        # Create placeholder post to bind to the post reply form
        @forum_post = @forum_topic.forum_posts.new

        set_page_title "Forums - " + @forum.name + " - " + @forum_topic.title

        # Increment topic views unless a postback (pagination,etc) or if the originating user
        @forum_topic.view! unless request.post? or (logged_in? and @forum_topic.user == current_user)
        
        # If an AJAX sort/filter/paginate request was called from the forum display...
        render(:partial => "/forum_posts/table", :layout => false) if request.xhr?    
    end  

    def new
        set_page_title "Forums - " + @forum.name + " - New Topic"

        @forum_topic = ForumTopic.new
        @forum_topic.forum_posts.build
    end

    def create      
        @forum_topic = @forum.forum_topics.build params[:forum_topic]          
        @forum_topic.user = current_user if current_user

        if @forum_topic.save            
            flash[:notice] = "Topic created"
            redirect_to forum_path(@forum.id) 
        else
            render :action => session[:action_name]
        end
    end

    def edit
        set_page_title "Forums - " + @forum.name + " - Edit '" + @forum_topic.title + "'"
    end

    def update
        @forum_topic.body = 'NOTBLANK'
        if @forum_topic.update_attributes(params[:forum_topic])
            flash[:notice] = "Topic updated."
            redirect_to forum_path(@forum_topic.forum_id)
        else
            render :action => session[:action_name]
        end 
        return false
    end

    def destroy
        @forum_topic.destroy

        flash[:notice] = "Topic deleted."
        redirect_to forum_path(@forum)
    end

    private
    
    def prepare_forum
        @forum = Forum.id_cached(params[:forum_id])
    end
    
    def prepare_forum_topic
        @forum_topic = @forum.forum_topics.find(params[:id])
    end

    def check_can_edit_topic
        @forum_topic = @forum.forum_topics.find(params[:id])

        unless can_edit_topic?
            flash[:warning] = "You do not have permission to edit this topic."
            redirect_to :back
            return false
        end
    end

    def check_can_create_post
        @forum = Forum.id_cached(params[:forum_id])

        unless can_create_post?
            flash[:warning] = "You do not have permission to create topics."
            redirect_to :back
            return false
        end
    end
end
