class NewsArticleCategory < ActiveRecord::Base
    has_many :news_articles
    
    named_scope :with_ordered,           :order => 'news_article_categories.title ASC'
    named_scope :with_articles,          :conditions => "news_article_categories.news_articles_count > 0"
    
    validates_uniqueness_of   :title
    
    class << self
		def all_cached
			Rails.cache.fetch('NewsArticleCategory.all') { NewsArticleCategory.with_articles.with_ordered }
		end
		
        def options_for_select
            Rails.cache.fetch('NewsArticleCategory.options_for_select') { NewsArticleCategory.with_ordered.find(:all).collect {|c| [ c.title, c.id ] } }
        end
    end
end