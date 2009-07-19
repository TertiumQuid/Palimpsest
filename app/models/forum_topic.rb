class ForumTopic < ActiveRecord::Base
    belongs_to    :forum, :counter_cache => true
    belongs_to    :user
    has_many      :forum_posts, :dependent => :destroy
    has_one       :recent_post, :order => "forum_posts.created_at ASC", :class_name => 'ForumPost'
    
    before_create     :set_default_replied_at
    before_update     :check_for_moved_topic
    after_create      :create_first_post
    after_save        :update_moved_topic_counter_cache
    before_destroy    :update_deleted_topic_counter_cache
  
    attr_accessor   :body
    attr_accessible :body, :title, :username, :sticky, :locked, :forum_id
    
    validates_presence_of   :title, :forum, :body
    validates_length_of     :title, :within => 3..32
    
    named_scope :with_posts,		:include => [:forum_posts]
    named_scope :with_recent_post,  :include => [:recent_post]
    
    def validate_associated_records_for_forum_posts() end
    
    def view!
        self.class.increment_counter :views_count, id
    end
    
    # Automatically derive a forum post based on the topic's data, and create! that post
    def create_first_post
        return if forum_posts.size > 0
        forum_posts.create! do |p|
            p.subject = title
            p.body = body
            p.user = user if user
            p.user_id = user.id if user
            p.username = user.username if user
        end
    end
    
    # Updates the cached post fields for the topic with the information of a given post
    def update_cached_post_fields(post)
        # these fields are not accessible to mass assignment
        remaining_post = post.frozen? ? recent_post : post
        if remaining_post
            self.class.update_all(['last_replied_at = ?, recent_post_id = ?, recent_post_user_id = ?, recent_post_username = ?', remaining_post.created_at, remaining_post.id, remaining_post.user_id, remaining_post.username], ['id = ?', id])
        else
            self.destroy
        end
    end
        
    protected

    def set_default_replied_at
        self.last_replied_at = Time.now.utc
    end
    
    private
    
    def check_for_moved_topic
        old_topic = ForumTopic.find(id)
        @old_forum_id = old_topic.forum_id if old_topic.forum_id != forum_id
        true
    end
    
    def update_moved_topic_counter_cache
        # if the topic moved forums
        if !frozen? && @old_forum_id && @old_forum_id != forum_id
            Forum.decrement_counter('forum_topics_count', @old_forum_id)
            Forum.increment_counter('forum_topics_count', forum_id)
            
            post_count = self.forum_posts.count
            old_forum = Forum.find(@old_forum_id)
            old_forum.update_attribute(:forum_posts_count, old_forum.forum_posts_count - post_count)
                    
            new_forum = Forum.find(forum_id)
            new_forum.update_attribute(:forum_posts_count, new_forum.forum_posts_count + post_count)
        end
    end
    
    # Decrement the post counter for the topic's associated forum; 
    # through associations don't seem to update a child's children, so
    # update_deleted_topic_counter_cache performs an explicit update instead.
    def update_deleted_topic_counter_cache
        self.forum_posts.build
        post_count = self.forum_posts.size
        forum = Forum.find(forum_id)
        forum.update_attribute(:forum_posts_count, forum.forum_posts_count - post_count)
    end
    
end
