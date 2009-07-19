class PrivateMessageRecipient < ActiveRecord::Base
    belongs_to :user
    belongs_to :private_message
    
    validates_presence_of     :private_message, :user
    
    named_scope :with_private_message, :include => [:private_message]
    named_scope :with_conversation, lambda { |*args| {:conditions => ["private_message_recipients.user_id = ? and private_messages.original_message_id = ?", args[0], args[1]]} } do
        def delete
            # Other users involved in a thread should still see the original recipients, so set delete flag instead of actually destroying
            each { |r| r.update_attribute(:has_deleted, true) }
        end
        
        def read
            each { |r| r.update_attribute(:has_read, true) }
        end
    end
end
