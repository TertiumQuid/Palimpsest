class CreateForumTopics < ActiveRecord::Migration
  def self.up
    create_table :forum_topics, :force => true do |t|
      t.integer     :forum_id,            :null => false
      t.integer     :user_id
      t.string      :title,               :null => false, :limit => 32
      t.integer     :views_count,         :default => 0
      t.integer     :forum_posts_count,   :default => 0
      t.boolean     :locked,              :default => false
      t.boolean     :sticky,              :default => false
      t.datetime    :last_replied_at
      t.integer     :recent_post_id
      t.integer     :recent_post_user_id
      t.string      :recent_post_username

      t.primary_key :id
      t.timestamps
    end
    
	add_index :forum_topics, [:forum_id,:sticky,:created_at]  
	
    ForumTopic.create do |t|
        t.forum_id = 2
        t.user = User.find(2)
        t.title = "Welcome to Palimpsest"
        t.body = "<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Phasellus dapibus sem. Mauris non diam sit amet arcu consequat vulputate. Etiam massa. Nullam sed erat id risus molestie ultricies. Nulla egestas fermentum est. Vestibulum erat urna, tincidunt sed, ornare in, tristique eget, tellus. Quisque fermentum. In hac habitasse platea dictumst. Phasellus semper, augue quis hendrerit lobortis, quam massa aliquam ligula, eget euismod risus orci ut nulla. Aliquam non diam. Donec purus augue, pulvinar a, congue in, tempus et, urna. Fusce aliquam molestie arcu. </p>"
    end
    
    User.find(2).update_attribute("forum_posts_count", 1)
  end

  def self.down
    drop_table :forum_topics
  end
end
