class ArticleSweeper < ActionController::Caching::Sweeper
	observe NewsArticle
	
	def after_save(record)
		Rails.cache.delete('NewsArticleCategory.all')
		Rails.cache.delete('NewsArticle.' << record.id.to_s) 
	end
	
	alias_method :after_destroy, :after_save
end