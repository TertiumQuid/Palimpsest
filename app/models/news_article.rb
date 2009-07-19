class NewsArticle < ActiveRecord::Base
    acts_as_taggable

    belongs_to    :user,                    :counter_cache => true
    belongs_to    :news_article_category,   :counter_cache => true
    
    has_many      :file_attachments,  :as => :parent,  :dependent => :destroy
    has_many      :comments,          :as => :parent,  :dependent => :destroy
    
    before_update     :check_for_moved_news_article_category
    after_update      :update_news_article_category_counter_cache, 
                      :save_file_attachments

    attr_accessor   :new_category, :new_category_title
    attr_accessible :new_category, :title, :body, :summary, :news_article_category_id, :moderate_comments, :comment_governance_id, :new_file_attachment_attributes, :extant_file_attachment_attributes
    
    validates_presence_of     :title, :body, :user_id
    validates_length_of       :title,      :within => 3..128
    
    named_scope :include_attachments, :include => [ :file_attachments ]   
    named_scope :include_category,    :include => [ :news_article_category ]
    named_scope :include_comments,    :include => [ :comments ]
    named_scope :include_tags,		  :include => [ :tags ]
    named_scope :with_ordered,        :order => 'news_articles.created_at DESC'
    named_scope :grouped_year_month,  :group => 'MONTH(news_articles.created_at), YEAR(news_articles.created_at)'
    named_scope :with_category,       lambda { |*args| {:conditions => ["news_article_categories.title = ?", args.first]} }
    named_scope :with_month,          lambda { |*args| {:conditions => ["YEAR(news_articles.created_at) = ? and MONTH(news_articles.created_at) = ?", args[0], args[1]]} }
    named_scope :with_day,            lambda { |*args| {:conditions => ["YEAR(news_articles.created_at) = ? and MONTH(news_articles.created_at) = ? and DAY(news_articles.created_at) = ?", args[0], args[1], args[2]]} }
    
    class << self	
		def id_cached(id)
			# memcache requires explicit model references or will throw a "undefined class/module" error
			# NewsArticleCategory;FileAttachment;Comment;Tags;Taggings
			# until this is solved in an environment-independent way, don't cache
			NewsArticle.include_category.include_attachments.include_tags.include_comments.find(id)
		end
		
        def article_count_by_date(articles,date)
            article_count = 0
            articles.each do |a|
                article_count += 1 if a.created_at.strftime("%m/%d/%Y") == date
            end

            article_count 
        end
        
        def find_by_date(year,month,day,page)
            if day
                NewsArticle.include_category.with_day(year,month,day).with_ordered.paginate :per_page => 8, :page => (page||=1)
            else
                NewsArticle.include_category.with_month(year,month).with_ordered.paginate :per_page => 8, :page => (page||=1)
            end
        end
        
        def find_by_tag(tag)
            NewsArticle.include_category.with_ordered.find_tagged_with(tag).paginate :per_page => 8, :page => (page||=1)
        end
        
        def find_by_category(category)
            NewsArticle.include_category.with_ordered.with_category(category).paginate :per_page => 8, :page => (page||=1)
        end
        
        # Removes delimting spaces, replaces phrase spaces with underscores, and strips all invalid tag characters, in that order.
        def format_tag_input(txt)
          txt ? txt.gsub(", ", ",").gsub(' ', '_').gsub(/[^a-zA-Z0-9#_,]/, '') : ''
        end
        
        # Returns a list of the first artlce from every distinct month where an article was created.
        def find_distinct_month_year_list
            NewsArticle.with_ordered.grouped_year_month
        end
        
        def month_year_count(date)
            NewsArticle.count('id', :conditions => ["YEAR(news_articles.created_at) = ? AND MONTH(news_articles.created_at) = ?", date.year, date.month]) 
        end
    end

    # Virtual method that creates a new article category record when passed a title, so that categories can be created with article updates. Also wraps
    # the new_category_title accessor
    def new_category=(title)
        unless title.blank?
            new_category = NewsArticleCategory.create( :title => title )
            self.errors.add("new category", " cannot be created because it is invalid. ") unless new_category.valid?
            self.news_article_category = new_category if new_category.valid?
            self.new_category_title = title
        end
    end
    
    # Virtual method for assigning child attachment files to articles
    def new_file_attachment_attributes=(file_attachment_attributes)
        file_attachment_attributes.each do |attributes|
            file_attachments.build(attributes) unless attributes["attachment"].blank?
        end
    end  

    def extant_file_attachment_attributes=(file_attachment_attributes)
        file_attachments.reject(&:new_record?).each do |attachment|
            attachments = file_attachment_attributes[attachment.id.to_s]
            
            if attachments
                attachment.attributes = attachments
            else
                file_attachments.delete(attachment)
            end
        end
    end      
	
	def approved_comments_count
		self.comments.with_approved.size
	end
    
    private
    
    def save_file_attachments
        file_attachments.each do |attachment|
          attachment.save
        end
    end
    
    def check_for_moved_news_article_category
        old_article = NewsArticle.find(id)
        @old_category_id = old_article.news_article_category_id if old_article.news_article_category_id != self.news_article_category_id
    end
      
    # if the article changed categories (and the new category wasn't just created, in which case the counter cache is already handled by ActiveRecord),
    # then update the appropriate article category counters
    def update_news_article_category_counter_cache
        if !frozen? && @old_category_id && self.new_category_title.blank?
            NewsArticleCategory.decrement_counter(:news_articles_count, @old_category_id)
            NewsArticleCategory.increment_counter(:news_articles_count, self.news_article_category_id)
        end
    end
end
