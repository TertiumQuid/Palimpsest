class PrivateMessagesController < ApplicationController
    include ApplicationHelper
    
    helper_method   :is_current_user_sender?, :is_viewing_received_box?
    
    before_filter   :check_authentication
    before_filter   :build_thread,                :only => [ :show, :update, :destroy ]
    before_filter   :check_daily_message_limit,   :only => [ :create, :update ]
    
    after_filter    :cache_action_name,           :only => [ :new, :edit, :show ]
    after_filter    :flag_as_read,                :only => [ :show ]
  
    def index
        set_page_title current_user.display_name + "'s Messages"

        sort = params[:sort].sub("_desc"," desc") unless params[:sort].blank?
        
        mailbox = params[:mailbox].nil? ? "inbox" : params[:mailbox]
        @private_messages = PrivateMessage.find_mailbox_conversations(current_user,mailbox,params[:page],sort)
        
        # If an AJAX sort/filter/paginate request was called from the private message display...
        render(:partial => "/private_messages/private_message_table", :layout => false) if request.xhr?         
    end

    def show
        set_page_title "Private Message"
        
        @private_message = current_user.private_messages.new
        @original_message = @private_messages.first
    end

    def new  
        set_page_title "Compose Message"
        
        @private_message = current_user.private_messages.new
    end

    def create
        set_page_title "Compose Message"
        
        compose_message
        
        # Validate against SPAMMY behavior
        check_flood_limit @users.uniq unless @users.nil?
        
        # For brevity and convinience, the error checking and the recipient assignment are addressed together, sequentially, in the following line
        if @private_message.errors.count == 0 and @private_message.save and (@users.uniq.each {|username| @private_message.recipients.create(:user_id => User.find_by_username(username).id) })              
            if ConfigurationSetting.get_setting_to_bool("EmailPrivateMessageNotices")
                @private_message.recipient_users.each do |u|
                    NotificationsMailer.deliver_private_message(@private_message,u)
                end
            end

            flash[:notice] = "Private message sent"
            redirect_to private_messages_path
        else
            render :action => session[:action_name]
        end
    end

    def edit    
    end

    # Private messages cannot actually be edited, but the update action presents a convinient way to handle replies separate from the creation of new PMs.
    def update  
        set_page_title "Private Message"
        
        compose_message
                
        # All threaded messages share the same original ID, so we'll just call the first record
        @private_message.original_message_id = original_message_id
        
        # Validate against SPAMMY behavior
        check_flood_limit @users.uniq unless @users.nil?
      
                
        # For brevity and convinience, the error checking and the recipient assignment are addressed together, sequentially, in the following line
        if @private_message.errors.count == 0 and @private_message.save and (@users.uniq.each {|username| @private_message.recipients.create(:user_id => User.find_by_username(username).id) })              
            if ConfigurationSetting.get_setting_to_bool("EmailPrivateMessageNotices")
                spawn do
                    @private_message.recipient_users.each do |u|
                        NotificationsMailer.deliver_private_message(@private_message,u)
                    end
                end
            end

            flash[:notice] = "Reply sent"
            redirect_to private_messages_path
        else
            @original_message = @private_messages.first
            render :action => session[:action_name]
        end 
    end

    def destroy
        PrivateMessage.delete_conversation_for_user(session[:user_id], original_message_id)
        flash[:notice] = "Conversation deleted"
        
        redirect_to private_messages_path
    end
    
    # Creates a new PM based on the form values supplied by the PM _form partial
    def compose_message
        @private_message = current_user.private_messages.new(
                                          :subject => params[:private_message][:subject], 
                                          :body => params[:private_message][:body], 
                                          :file_attachment_attributes => params[:private_message][:file_attachment_attributes], 
                                          :username => current_user.username)
        
        # Before saving, evaluate (1) the message itself, (2) the presence of recipients, and (3) correctly chosen recipients
        unless params[:recipient_list].blank?
            @users = params[:recipient_list].split()
            @users.map {|n|"'" + n.strip + "'"} 
            @users.each do |username|
                user = User.with_active.find_by_username(username)
                @private_message.errors.add("recipients", " includes a user, '" + username + "', that does not exist or is inactive") unless user
            end
        else
            @private_message.errors.add("recipients", " must be chosen")
        end
    end
    
    # Convinience method that validates a message against SPAM flood limits
    def check_flood_limit(users)
          flood_limit = ConfigurationSetting.get_setting( 'PrivateMessageRecipientLimit' ).to_i
          @private_message.errors.add("recipients", " may have no more than " + flood_limit.to_s + " recipients on one message" ) if users.size > flood_limit
    end
    
    # Check if a user has reached the daily limit of private messages, redirecting them to the index if so
    def check_daily_message_limit
          flood_limit = ConfigurationSetting.get_setting( 'DailyPrivateMessageLimit' ).to_i
          today = Date.today.strftime('%Y-%m-%d')
          if not current_user.sent_private_messages.with_date(today).all.size <= flood_limit            
              flash[:warning] = "You have already sent the maximum of " + flood_limit.to_s + " messages for the day."
              redirect_to private_messages_path
          end
    end
    
    def is_viewing_received_box?
        params[:mailbox].blank? or params[:mailbox] == "inbox"
    end
    
    def is_current_user_sender?(msg)
        msg.user_id == session[:user_id]
    end
    
    private
    
    def flag_as_read
        PrivateMessage.flag_conversation_as_read(session[:user_id],original_message_id) if @private_messages.with_unread.all.size > 0
    end
    
    # Convinience method that builds a list of PMs based on the requested PM, filtered for the current user
    def build_thread
        @private_messages = PrivateMessage.find_conversation(current_user,params[:id])
    end
    
    # Convinience method to return the parent pm of a thread; requires the :build_thread macro
    def original_message_id        
        @private_messages.first.original_message_id # All threaded messages share the same original ID, so we'll just call the first record
    end
end