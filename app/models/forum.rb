class Forum < ActiveRecord::Base
    has_many :forum_topics, :order => 'sticky DESC, created_at DESC', :dependent => :destroy
    has_many :forum_posts,  :through => :forum_topics, :source => :forum_posts, :order => "forum_posts.created_at DESC", :class_name => 'ForumPost', :dependent => :destroy
    has_one  :recent_post,  :through => :forum_topics, :source => :forum_posts, :order => "forum_posts.created_at DESC", :class_name => 'ForumPost'
    
    attr_accessible :name, :description
    
    validates_presence_of     :name
    validates_length_of       :name,      :within => 2..32
		
    class << self
		def all_cached
			Rails.cache.fetch('Forum.all') { Forum.find(:all) }
		end
		
		def id_cached(id)
			Rails.cache.fetch('Forum.' << id.to_s) { Forum.find(id) }
		end
    end
end
