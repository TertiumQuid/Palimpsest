class PrivateMessage < ActiveRecord::Base
    belongs_to    :user, :include => [:account_status]
    belongs_to    :original_message,  :class_name => "PrivateMessage", :conditions => "private_messages.original_message_id is not null"
    
    has_many      :recipient_users,   :class_name => "User", :through => :recipients, :source => "user", :order => "users.username ASC"
    has_many      :recipients,        :class_name => "PrivateMessageRecipient", :foreign_key => "private_message_id", :dependent => :destroy 
    has_many      :replies,           :class_name => "PrivateMessage", :foreign_key => "original_message_id", :dependent => :destroy
  
    has_many      :file_attachments, :as => :parent,  :dependent => :destroy
  
    after_create    :associate_recipients, :check_original_message_id
    
    attr_accessible :subject, :body, :username, :file_attachment_attributes
    
    validates_presence_of     :subject, :body
    validates_presence_of     :user, :message => "was not found"
    validates_length_of       :subject, :maximum => 128
    
    named_scope :with_sender,                 :include => [:user]
    named_scope :with_recipients,             :include => [:recipients]
    named_scope :with_unread,                 :include => [:recipients], :conditions =>["private_message_recipients.has_read=0"]
    named_scope :with_recipient_users,        :include => [:recipient_users]
    
    named_scope :with_ordered,                :order => 'private_messages.created_at DESC'
    named_scope :with_replies,                :include => [:replies]    
    named_scope :with_attachments,            :include => [:file_attachments]    
    named_scope :with_original_message,       :include => [:original_message]
    named_scope :with_date,                   lambda { |*args| {:conditions => ["private_messages.created_at", args.first]} }
    named_scope :with_user_sent_messages,     lambda { |*args| {:conditions => ["user_id = ?", args.first]} }
    named_scope :with_user_received_messages, lambda { |*args| {:conditions => ["user_id = ?", args.first]} }
    named_scope :with_user,                   lambda { |*args| {:conditions => ["(private_messages.user_id = ? or private_message_recipients.user_id = ?)", args.first, args.first]} } 
    named_scope :with_thread,                 lambda { |*args| {:conditions => ["(private_messages.original_message_id = ? or private_messages.id = ?)", args.first, args.first]} }
  
    named_scope :group_by_threads, :group => "private_messages.original_message_id"
    
    class << self
        # Returns a distinct list of conversations containing one or more private messages visible to a given user
        def find_mailbox_conversations(user,mailbox,page=nil,sort=nil)
            if mailbox == "inbox"
                user.private_messages.group_by_threads.with_original_message.with_sender.paginate :per_page => 10, :page => page, :order => "private_messages." << (sort||='created_at desc')
            elsif mailbox == "sent"
                user.sent_private_messages.with_ordered.group_by_threads.with_recipient_users.paginate :per_page => 10, :page => page, :order => "private_messages." << (sort||='created_at desc')
            end
        end

        def find_conversation(user,message_id)
            # Track how elements of the view are displayed based on whether showing a sent or received message
            viewing_received = true

            # Secure that the user has participated in the message thread as sender or receiver
            begin
                msg = user.private_messages.with_sender.find(message_id) 
            rescue
                msg ||= user.sent_private_messages.with_sender.find(message_id)
                viewing_received = false
            end

            # Build a "thread" of messages from those messages within the thread that the current user can see
            private_messages = PrivateMessage.with_thread(msg.original_message_id).with_recipients.with_recipient_users.with_user(user.id).with_attachments.with_ordered
        end

        def delete_conversation_for_user(user_id,original_message_id)
            PrivateMessageRecipient.with_private_message.with_conversation(user_id,original_message_id).delete
        end

        def flag_conversation_as_read(user_id,original_message_id)
            PrivateMessageRecipient.with_private_message.with_conversation(user_id,original_message_id).read
        end
    end
  
    # Virtual method for assigning child attachment files to private messages
    def file_attachment_attributes=(file_attachment_attributes)
        return if file_attachment_attributes.nil?
        
        file_attachment_attributes.each do |attributes|
            file_attachments.build(attributes)
        end
    end
  
    # Is the first or only message sent within a thread, else is a reply.
    def is_reply?
        return self.id != self.original_message_id
    end
    
    # Is user recipient for any message which they have not yet read?
    def has_unread_messages?(user_id)
        PrivateMessage.with_recipient_users.with_thread(self.original_message_id).with_user(user_id).with_unread.size > 0
    end
    
    # Count of individual messages within the thread that are visible to a given user
    def conversaion_count(user_id)
        PrivateMessage.with_recipient_users.with_thread(self.original_message_id).with_user(user_id).size
    end
    
    private

    # If the message is not a reply, assign its own id as the original message in order to help when aggreating threads
    def check_original_message_id
        self.update_attribute("original_message_id", self.id) if self.original_message_id.nil?
    end
    
    # Cannot always be certain in what order recipients will be added, so ensure all current recipient records inherit the newly created id
    def associate_recipients
        recipients.each { |r| r.private_message_id = self.id }
    end
end
