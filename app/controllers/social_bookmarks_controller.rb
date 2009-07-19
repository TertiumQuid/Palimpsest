class SocialBookmarksController < ApplicationController
    include ApplicationHelper
  
    before_filter   :check_authorization
    
    def index
        set_page_title "Social Bookmarklets"
        
        @social_bookmarks = SocialBookmark.all
    end
    
    def new
        set_page_title "New Social Bookmarklet"
        
        @social_bookmark = SocialBookmark.new
    end
    
    def create
        set_page_title "New Social Bookmarklet"
        @social_bookmark = SocialBookmark.new(params[:social_bookmark])

        if @social_bookmark.save
            flash[:notice] = "Social bookmark #{@social_bookmark.name} created"
            redirect_to social_bookmarks_path
        else
            render :action => :new
        end
    end
    
    def edit
        @social_bookmark = SocialBookmark.find(params[:id])
        
        set_page_title "Edit Social Bookmarklet - " << @social_bookmark.name
    end
    
    def update
        @social_bookmark = SocialBookmark.find(params[:id])
        
        set_page_title "Edit Social Bookmarklet - " << @social_bookmark.name
        
        if @social_bookmark.update_attributes(params[:social_bookmark])
            flash[:notice] = "Social bookmark #{@social_bookmark.name} updated"
            redirect_to social_bookmarks_path
        else
            render :action => :edit
        end  
    end
    
    def destroy
        social_bookmark = SocialBookmark.find(params[:id])
        original = social_bookmark.icon.path if social_bookmark.icon.exists?
        bookmarklet = social_bookmark.icon.path if social_bookmark.icon.exists?
        social_bookmark.destroy
        
        FileUtils.rm_rf(original) unless original.blank?
        FileUtils.rm_rf(bookmarklet) unless bookmarklet.blank?
        
        flash[:notice] = "Social bookmarklet deleted"
        redirect_to social_bookmarks_path
    end
end
