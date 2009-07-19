class CreateComments < ActiveRecord::Migration
  def self.up
      create_table :comments, :force => true do |t|
        t.integer   :parent_id
        t.string    :parent_type,   :limit => 64
        t.boolean   :is_approved, :null => false, :default => false
        
        t.integer   :user_id
        t.string    :author
        t.string    :email
        t.string    :ip_address
        t.string    :website_url
      
        t.text      :body,         :null => false

        t.timestamps
      end     
    
      create_table :comment_governances, :force => true do |t|
        t.string  :name,         :null => false
        t.string  :description
      end
	  
	  add_index :comments, :parent_id

      CommentGovernance.create(:name=>"Anyone",:description=>'Anyone, both users and anonymous vistors, can comment')
      CommentGovernance.create(:name=>"Users Only",:description=>'Only registered users can comment')
      CommentGovernance.create(:name=>"Comments Closed",:description=>'No comments allowed')
  end

  def self.down
      drop_table :comments
      drop_table :comment_governances
  end
end
