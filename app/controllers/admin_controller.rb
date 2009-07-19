class AdminController < ApplicationController
    include ApplicationHelper

    before_filter   :check_authorization

    def configuration
        set_page_title "Site Configuration"

        @configuration_setting = ConfigurationSetting.new
    end

    def configure
        set_page_title "Site Configuration"

        @configuration_setting = ConfigurationSetting.new

        configuration_complete = false
        ConfigurationSetting.transaction do
            @settings = ConfigurationSetting.find(:all)

            # Store salt for later comparison
            @old_salt = ConfigurationSetting.get_setting("Salt")

            @settings.each do |setting|
                setting.update_attribute("value", params[setting.key] ||= 'false')
                @configuration_setting.errors.add_to_base(setting.errors.full_messages) unless setting.errors.empty?
            end
            configuration_complete = true
        end

        if configuration_complete
            # If salt is changed, invalidate hashed fields
            User.security.nullify_authentication_hash if @old_salt != ConfigurationSetting.get_setting("Salt")

            flash[:notice] = "Settings updated."
            redirect_to admin_configuration_path and return
        else
            render :action => :configuration
        end
    end

    def audit_logs
        set_page_title "Site Audit Logs"

        sort = params[:sort].sub("_desc"," desc") unless params[:sort].blank?
        
        @audit_logs = AuditLog.find_filtered_audit_logs(params[:username],
                                                         params[:ip_address],
                                                         params[:log_event],
                                                         params[:log_action],
                                                         params[:start_date],
                                                         params[:end_date],
                                                         sort).paginate :per_page => 25, :page => params[:page]
                                                                   

        # If an AJAX sort/filter/paginate request was called from the audit display...
        render(:partial => "/admin/audit_log_table", :layout => false) if request.xhr?
    end 

    def exception_logs
        set_page_title "Site Exception Logs"

        @exception_logs = ExceptionLog.with_ordered.find_filtered_exception_logs(params[:username],
                                                                                 params[:ip_address],
                                                                                 params[:exception_type],
                                                                                 params[:log_action],
                                                                                 params[:start_date],
                                                                                 params[:end_date]).paginate :per_page => 25, :page => params[:page]
        @exception_users = User.with_ordered_by_exception_logs(params[:account_status_id] || 2).find(:all)
    end  
    
    def ip_addresses
        set_page_title "IP Address Usage"      
        
        # Process commands to ban/unban an ip address
        if param_posted?(:ban) 
            unless IpBan.exists?(['ip_address = ?', "#{params[:ban]}"])
                IpBan.create(:ip_address => params[:ban]) 
                flash[:notice] = "IP Address #{params[:ban]} banned!"
            else
                flash[:notice] = "IP Address #{params[:ban]} is <u>already banned</u>"
            end
        elsif param_posted?(:unban) 
            IpBan.find(params[:unban]).destroy
            flash[:notice] = "IP Address #{params[:ban]} unbanned!"
        end
        
        sort = params[:sort].sub("_desc"," desc") unless params[:sort].blank?
        
        # Find all unique ip/username combinations that have been logged
        @ips = AuditLog.find_used_ip_addresses(params[:query],sort).paginate :per_page => 25, :page => params[:page]
        
        # Find all ip addresses that have been logged for more than one user
        @multiples = AuditLog.find_multiple_users
        
        @ip_bans = IpBan.find_ip_addresses(params[:ip_ban_query])

        # If an AJAX sort/filter/paginate request was called from the ip address display...
        render(:partial => "/admin/ip_address_table", :layout => false) if request.xhr? and not param_posted?(:ip_ban_query)
        render(:partial => "/admin/ip_address_ban_table", :layout => false) if request.xhr? and param_posted?(:ip_ban_query)        
    end

    def file_storage
        set_page_title "File Storage"

        if param_posted?(:purge_avatars)
            User.purge_avatars! 
            flash[:notice] = "Avatar files purged."
        end
        if param_posted?(:purge_attachments)
            FileAttachment.purge_attachments! 
            flash[:notice] = "Attachment files purged."
        end
    end
end
