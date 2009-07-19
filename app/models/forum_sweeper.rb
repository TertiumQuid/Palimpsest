class ForumSweeper < ActionController::Caching::Sweeper
	observe Forum, ForumTopic, ForumPost
	
	def after_save(record)
		Rails.cache.delete('Forum.all')
		
		# Delete parents (when necessary) in order to recalculate cache counters and associations
		if record.is_a?(ForumPost)
			Rails.cache.delete('Forum.' << record.forum_topic.forum_id.to_s) 
			Rails.cache.delete('ForumTopic.' << record.forum_topic_id.to_s) 
		elsif record.is_a?(ForumTopic)
			Rails.cache.delete('Forum.' << record.forum_id.to_s) 
		elsif record.is_a?(Forum)
			Rails.cache.delete('Forum.' << record.id.to_s) 
		end
	end
	
	alias_method :after_destroy, :after_save
end