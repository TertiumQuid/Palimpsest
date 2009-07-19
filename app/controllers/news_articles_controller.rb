class NewsArticlesController < ApplicationController
    include ApplicationHelper, NewsArticlesHelper, CommentsHelper

    before_filter   :prepare_article,             :only => [ :show, :edit, :update, :destroy ]
    
    before_filter   :check_authentication,        :except => [ :index, :show ]       
    before_filter   :build_date,                  :only => [ :index, :show ]
    after_filter    :cache_action_name,           :only => [ :new, :edit ]
  
    def index
        set_page_title "News"
      
        # The article index provides the facade for several types of routed links and searches. 
        
        if not params[:tag].blank?
        # View by tag
            @news_articles = NewsArticle.include_comments.find_by_tag(params[:tag])
            @filter_header = "Tagged as \"#{params[:tag]}\""
        elsif not params[:category].blank?
        # View by article category
            @news_articles = NewsArticle.include_comments.find_by_category(params[:category])
            @filter_header = "Categorized under \"#{params[:category]}\""
        else
        # View by date
            @news_articles = NewsArticle.include_comments.find_by_date(@year,@month,@day,params[:page])
            
            @filter_header = "From #{@date.strftime('%B')}"
            @filter_header << " " << @day.to_s if @day
            @filter_header << ", " << @year.to_s
        end
    end

    def show		
        @comment = Comment.new
		@comments = @news_article.comments.with_approved
        
        set_page_title "News - " << @news_article.title
    end

    def new
        set_page_title "Create News Article"
        
        @tags = Tag.find(:all, :order => 'name asc')
        @news_article = NewsArticle.new
    end

    def create
        @news_article = NewsArticle.new(params[:news_article]) do |a|
            a.user = current_user
            a.user_id = session[:user_id]
            a.tag_list = NewsArticle.format_tag_input(params[:tags])
        end
                
        if @news_article.save
            flash[:notice] = "News article published"
            redirect_to news_articles_path
        else
            set_page_title "Create News Article"
            @tags = Tag.find(:all, :order => 'name asc')
            render :action => session[:action_name] 
        end
    end

    def edit
        set_page_title "Edit News Article: " + @news_article.title
        
		@comments = @news_article.comments
        @tags = Tag.find(:all, :order => 'name asc')

    end

    def update
        @news_article.tag_list = NewsArticle.format_tag_input(params[:tags])
        params[:news_article][:extant_file_attachment_attributes] ||= {}
                
        if @news_article.update_attributes(params[:news_article])
            flash[:notice] = "News article updated."
            redirect_to news_article_path(@news_article.id) 
        else
            set_page_title "Edit News Article: " + @news_article.title
            @tags = Tag.find(:all, :order => 'name asc').remove(@news_article.tag_list)
            render :action => session[:action_name]
        end 
    end

    def destroy
        flash[:notice] = "Article deleted"
        
        redirect_to news_articles_path
    end
        
    private
    
    def prepare_article
        @news_article = NewsArticle.id_cached(params[:id])
		@parent = @news_article # Used for polymorphic associations
    end
    
    def build_date
        @year = params[:year].nil? ? Time.now.year : params[:year].to_i 
        @month = params[:month].nil? ? Time.now.month : params[:month].to_i
        @day = params[:day]

        @date = Time.local(@year,@month,@day) 
    end
end