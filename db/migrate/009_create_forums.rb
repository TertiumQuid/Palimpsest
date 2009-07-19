class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums, :force => true do |t|
      t.string  :name, :null => false, :limit => 32
      t.string  :description
      t.integer :forum_topics_count,  :default => 0
      t.integer :forum_posts_count,   :default => 0
      
      t.primary_key :id
      t.timestamps
    end
    
    Forum.create(:name=>"Administration",:description=>"Site management, user administration, and staff discussion.")
    Forum.create(:name=>"General",:description=>"Site community discussion.")
  end

  def self.down
    drop_table :forums
  end
end
