class Comment < ActiveRecord::Base
    belongs_to    :user
    belongs_to    :parent,  :polymorphic => true, :counter_cache => true
    
    attr_accessible :author, :email, :website_url, :body
    
    validates_presence_of     :body
    
    named_scope :with_unapproved, :conditions =>["comments.is_approved=0"]
    named_scope :with_approved,   :conditions =>["comments.is_approved=1"]
	
    class << self
		def find_comment(id)
			Comment.find(id)		
		end
	end
end
