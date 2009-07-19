class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions, :force => true do |t|
      t.string :name,         :null => false
      t.string :controller,   :null => false
      t.string :action,       :null => false
      t.string :description
      t.timestamps
    end
	
    add_index :permissions, :name 
    add_index :permissions, [ :controller, :action ] 
    
    Permission.create(:name=>"Configure Site",:controller=>"admin",:action=>"configuration configure audit_logs exception_logs file_storage ip_addresses",:description=>"Able to configure global site settings, security, functionality, &c.")
    Permission.create(:name=>"Create Users",:controller=>"users",:action=>"new create",:description=>"Able to create new system users.")
    Permission.create(:name=>"View Users",:controller=>"users",:action=>"index show dashboard",:description=>"Able to view system users.")
    Permission.create(:name=>"Edit Users",:controller=>"users",:action=>"edit update",:description=>"Able to edit all system users.")
    Permission.create(:name=>"Delete Users",:controller=>"users",:action=>"destroy delete",:description=>"Able to remove system users.")
    Permission.create(:name=>"Moderate Forums",:controller=>"forums",:action=>"",:description=>"Able to mange forums, posts, and topics.")
    Permission.create(:name=>"Publish News Articles",:controller=>"news_articles",:action=>"news_article",:description=>"Able to created, edit, delete, and moderate site news.")
    Permission.create(:name=>"Manage Social Bookmarks",:controller=>"social_bookmarks",:action=>"new create edit update index destroy",:description=>"Able to manage site bookmarklet items.")
    Permission.create(:name=>"Manage IPs",:controller=>"ip_bans",:action=>"new create destroy",:description=>"Able to ban and unban users by ip address, and view ip addresses.")
  end

  def self.down
    drop_table :permissions
  end
end
