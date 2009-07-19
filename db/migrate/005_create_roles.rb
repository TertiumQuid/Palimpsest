class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :name,         :null => false
      t.string :description
      
      t.timestamps
    end
    
    create_table :roles_users, :force => true, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end
    
    create_table :permissions_roles, :force => true, :id => false do |t|
      t.integer :permission_id
      t.integer :role_id
    end
    
    add_index :roles,				:name 
    add_index :roles_users,			:user_id
    add_index :permissions_roles,	:user_id
	
    Role.create(:name=>"Administrator",:description=>"Authorized for all site and system management")
    Role.create(:name=>"Staff",:description=>"Authorized for site management")
    Role.create(:name=>"User",:description=>"Authorized for site use")
    Role.create(:name=>"Moderator",:description=>"Authorized for forum management and user moderation")
    
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Configure Site")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Create Users")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("View Users")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Edit Users")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Delete Users")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Moderate Forums")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Publish News Articles")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Manage Social Bookmarks")
    Role.find_by_name("Administrator").permissions << Permission.find_by_name("Manage IPs")
    
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Create Users")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("View Users")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Edit Users")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Delete Users")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Moderate Forums")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Publish News Articles")
    Role.find_by_name("Staff").permissions << Permission.find_by_name("Manage IPs")
    
    Role.find_by_name("User").permissions << Permission.find_by_name("View Users")
    
    Role.find_by_name("Moderator").permissions << Permission.find_by_name("View Users")
    Role.find_by_name("Moderator").permissions << Permission.find_by_name("Moderate Forums")
  end

  def self.down
    drop_table :roles
    drop_table :roles_users
    drop_table :permissions_roles
  end
end