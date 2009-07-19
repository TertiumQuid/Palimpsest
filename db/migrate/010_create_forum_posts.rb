class CreateForumPosts < ActiveRecord::Migration
	def self.up
		create_table :forum_posts, :force => true do |t|
			t.integer :user_id
			t.integer :forum_topic_id,    :null => false
			t.string  :username,          :limit => 32
			t.string  :subject,           :limit => 32
			t.text    :body,              :null => false
			
			t.timestamps
		end
		
		add_index :forum_posts, [:forum_topic_id,:created_at]  
	end

	def self.down
		drop_table :forum_posts
	end
end
