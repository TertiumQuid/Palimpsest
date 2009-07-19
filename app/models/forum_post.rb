class ForumPost < ActiveRecord::Base
    belongs_to :forum_topic, :counter_cache => true, :foreign_key => "forum_topic_id"
    belongs_to :user, :counter_cache => true, :include => [ :session ]

    before_create   :check_for_subject
    after_create    :increment_counter_cache, :update_cached_fields
    after_destroy   :decrement_counter_cache, :update_cached_fields
    
    validates_presence_of     :body
    validates_length_of       :subject,      :within => 3..32
    
    named_scope :with_ordered,			:order => 'forum_posts.created_at DESC'
    named_scope :include_forum_topic,	:include => [:forum_topic]
    
    class << self
        def get_user_forum_posts(user_id)
            ForumPost.with_ordered.include_forum_topic.find :all, :conditions => {:user_id => user_id}
        end

        def get_recent_forum_posts(forum_id,limit=10)
            ForumPost.with_ordered.include_forum_topic.find :all, :include => [:forum_topic], :conditions => ["forum_topics.forum_id=?", forum_id ], :limit => limit
        end

        def get_recent_posts(limit=10)
            ForumPost.with_ordered.include_forum_topic.find :all, :limit => limit
        end
    end
    
    def user_display_name
        self.username ||= "anonymous"
    end
    
    def subject
        self[:subject].blank? ? "RE: " + forum_topic.title : self[:subject]
    end
    
    def is_author?(current_user_id)
        self.user_id and current_user_id == self.user_id
    end
    
    def is_only_post_in_topic?
        self.forum_topic.forum_posts_count == 1
    end
    
    def has_been_edited?
        self.updated_at > self.created_at
    end
    
    protected
    
    def update_cached_fields
        forum_topic.update_cached_post_fields(self)
    end    
    
    private

    def check_for_subject
        self.subject = "RE: " + self.forum_topic.title if self.subject.blank?
    end
    
    def increment_counter_cache
        Forum.increment_counter( 'forum_posts_count', self.forum_topic.forum.id )
    end

    def decrement_counter_cache
        Forum.decrement_counter( 'forum_posts_count', self.forum_topic.forum.id )
    end
end
