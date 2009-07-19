class User < ActiveRecord::Base
    has_and_belongs_to_many   :roles
    
    has_many                  :forum_posts
    has_many                  :forum_topics
    
    has_many                  :private_message_recipients,      :conditions => "private_message_recipients.has_deleted = 0", :dependent => :destroy  
    has_many                  :unread_private_message_receipts, :class_name => "PrivateMessageRecipient", :conditions => "private_message_recipients.has_read = 0 and private_message_recipients.has_deleted = 0"
    has_many                  :private_messages,                :through => :private_message_recipients, :order => "private_messages.created_at DESC"
    has_many                  :sent_private_messages,           :class_name => "PrivateMessage", :order => "private_messages.created_at DESC"
    
    has_many                  :audit_logs
    has_many                  :exception_logs
    
    has_one                   :session, :order => "sessions.created_at DESC"
    
    belongs_to                :account_status
            
    after_create    :assign_user_to_default_role, :generate_authentication_hash
  
    attr_accessor   :remember_me            # stores cookie to automatically login users
    attr_accessor   :current_password       # used for confirmation during password change
    
    attr_accessible :username, :email, :display_name, :timezone, :remember_me, :password, :current_passowrd, :password_confirmation, :avatar, :website_url, :signature, :personal_text
  
    validates_uniqueness_of   :username, :email
    validates_presence_of     :username, :email, :password
    validates_length_of       :username,      :within => 3..32
    validates_length_of       :display_name,  :within => 3..64
    validates_length_of       :password,      :within => 4..16
    validates_confirmation_of :password
    
    validates_format_of       :username, :with => /^[A-Z0-9_]*$/i, :message => "must contain only letters, numbers, and underscores"
    validates_format_of       :email, :with => /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i, :message => "must be a valid email address"
    
    has_attached_file                 :avatar, 
                                      :default_url => "/:attachment/blank_avatar_:style.png", 
                                      :styles => { :normal => "100x100#", :medium => "80x80#", :small => "64x64#", :thumbnail => "40x40#" }
    validates_attachment_size         :avatar, :in => 0.kilobytes...500.kilobytes
    validates_attachment_content_type :avatar, { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/pjpeg'] }
    
    named_scope :with_active, :include => [:account_status], :conditions =>["account_statuses.active=1"]
    named_scope :with_ordered, :order => 'users.display_name ASC'
    named_scope :with_ordered_by_exception_logs, lambda { |*args| {:conditions =>["users.exception_logs_count > 0 and users.account_status_id = ?", (args.size > 0 ? args[0] : 2)], :order => 'users.exception_logs_count DESC'} }
  
    named_scope :security do
        def nullify_authentication_hash
            each { |u| u.update_attribute(:authentication_hash, nil) }
        end
    end
    
    class << self
        def find_by_login(username,password)
            User.find(:first, :include => [:account_status], :conditions =>["username = ? and password = ?", username, password])
        end

        def find_filtered_users(letter=nil,account_status_id=2)
            conditions = Array.new
            conditions << "display_name like :display_name " if not letter.nil?
            conditions << "account_status_id = :account_status_id" if not account_status_id.nil?
            User.find(:all, :include => [:session], :conditions =>[conditions.join(" and "), { :display_name => letter ? letter+'%' : nil, :account_status_id => account_status_id}], :order => "display_name")
        end  

        # Deletes all user avatar field associations and removes avatar images from public avatar folder (except default avatar images)
        def purge_avatars!
            User.all.each {|user| user.update_attribute("avatar",nil) }
            Dir.glob("public/avatars/*").each{|f| FileUtils.rm_rf(f) if File.directory?(f)}
        end
    end
  
    def display_name
        self[:display_name] ||= self[:username]
    end
    
    def ip_address_display
        self[:ip_address] || "N/A"
    end
    
    def session_status
        if self.session and self.session.updated_at > Time.now.utc - 2.minutes
            "online"
        elsif self.session and self.session.updated_at > Time.now.utc - 15.minutes
            "away"
        else
            "offline"
        end
    end
    
    def login!(session)
        session[:user_id] = self.id
    end
  
    def self.logout!(session, cookies)
        cookies.delete(:remember_me)
        cookies.delete(:authorization_token)
        session.delete
    end
  
    # Clears password members for clean postback to forms
    def clear_password!
        self.password = nil
        self.password_confirmation = nil
        self.current_password = nil
    end
    
    # Returns true if params[:user][:current_password] matches password
    def correct_password?(params)
        current_password = params[:user][:current_password]
        password == current_password
    end
    
    # Generate messages for password errors
    def password_errors(params)
        # User User model's valid? method to generate error messages for a password mismatch (if any)
        self.password = params[:user][:password]
        self.password_confirmation = params[:user][:password_confirmation]
        valid?
        
        # The current password is incorrect, so add an error message
        errors.add(:current_password, "is incorrect")
    end
    
    def is_admin?
      self.roles.detect { |role| role.name == "Administrator" }
    end
    
    # Remember a user for future login
    def remember!(cookies)
        cookies[:remember_me] = { :value => "1", :expires => 10.years.from_now}
        self.authorization_token = Digest::SHA1.hexdigest( "#{self.username}:#{self.password}")
        self.save!
        cookies[:authorization_token] = { :value => self.authorization_token, :expires => 10.years.from_now }
    end
    
    # Forget a user's login status
    def forget!(cookies)
        cookies.delete(:remember_me)
        cookies.delete(:authorization_token)
    end
    
    # Returns true if the users wants login status remembered
    def remember_me?
        remember_me == "1"
    end
    
    protected
    
    def assign_user_to_default_role
        unless self.new_record?
          roles << Role.find_by_name( ConfigurationSetting.get_setting( 'DefaultUserRole' ) )
        end
    end
    
    private
    
    # Generate a unique hash key for the user for secure identification for validation links, etc.
    def generate_authentication_hash
        salt = ConfigurationSetting.get_setting( 'Salt' )
        self.update_attribute("authentication_hash", Digest::SHA1.hexdigest( "#{self.created_at}:#{salt}:#{self.id}"))
    end
end
