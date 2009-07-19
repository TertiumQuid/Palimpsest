class CreateUsers < ActiveRecord::Migration
  def self.up
		create_table :users, :force => true do |t|
		  t.integer   :account_status_id,  :null => false, :default => 2
		  t.string    :username,       :null => false,   :limit => 32
		  t.string    :display_name,   :limit => 64
		  t.string    :email,          :null => false
		  t.string    :password,       :null => false,   :limit => 64
		  t.string    :signature
		  t.string    :website_url
		  t.string    :ip_address
		  t.text      :personal_text
		  t.string    :timezone
		  t.string    :authorization_token
		  t.string    :authentication_hash
		  t.datetime  :last_login_time
		  
		  t.integer   :forum_posts_count,      :default => 0
		  t.integer   :exception_logs_count,   :default => 0
		  t.integer   :news_articles_count,    :default => 0
		  t.integer   :comments_count,         :default => 0
		  
		  t.string    :avatar_file_name
		  t.string    :avatar_content_type
		  t.integer   :avatar_file_size  
		  
		  t.timestamps
		end
	
		add_index :users, [:username]
	    
		User.create(:username=>'admin',:display_name=>'Administrator',:email=>'admin@example.com',:password=>'admin')
		User.create(:username=>'staff',:display_name=>'Staff',:email=>'staff@example.com',:password=>'staff')
		User.create(:username=>'user',:display_name=>'User',:email=>'user@example.com',:password=>'user')
	  
		User.find_by_username("admin").roles << Role.find_by_name("Administrator")
		User.find_by_username("staff").roles << Role.find_by_name("Staff")
		User.find_by_username("user").roles << Role.find_by_name("User")
	  end

	  def self.down
		drop_table :users    
	  end
end
