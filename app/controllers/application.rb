# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    helper :all # include all helpers, all the time
    helper_method :current_user, 
                  :belongs_to_role?, 
                  :has_permission?, 
                  :can_edit_post?, 
                  :logged_in?, 
                  :is_admin?, 
                  :current_controller?, 
                  :show_user_ip?,
                  :has_no_records?

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery :secret => 'c86687742151cb5615b80674a0a2fa9e'

    before_filter   :check_cookie_autentication, :log_page_views
    before_filter   :update_session_timestamp
  
    after_filter    :cache_request_uri

    session :session_key => 'palimpsest_session_id'

#    rescue_from Exception do |exception|
#        respond_to do |format|
#           format.html { render:file => "#{RAILS_ROOT}/public/500.html", :status => "500 Error" }
#           format.xml { render :xml => exception.to_xml, :status => 500 }
#        end
#
#        ExceptionLog.create do |l|
#            l.user_id = logged_in? ? current_user.id : nil
#            l.username = logged_in? ? current_user.username : nil
#            l.ip_address = request.remote_ip
#            l.controller = controller_name
#            l.action = action_name
#            l.exception_type = exception.type.to_s
#            l.message = exception.message
#            l.host = request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"]
#            l.backtrace = exception.backtrace
#            l.params = (params.map do |key,value|
#                key.to_s + "=" + value.to_s
#            end).join(',')
#        end
#        return false
#    end
    
    # Check for a valid authorization cookie, possibly logging the user in.
    def check_cookie_autentication
        if cookies[:authorization_token] and not session[:user_id]
            user = User.find_by_authorization_token(cookies[:authorization_token])
            if user
                user.login!(session)
                redirect_to dashboard_users_path
            end
        end
    end

    # Check if a user has permission against the request action/controller, and redirect them if authorization fails
    def check_authorization      
        user = current_user
        unless session["permission_" + action_name + "_" + controller_name] && user
            unless logged_in? and user.roles.detect { |role|
                role.permissions.detect { |permission|
                  permission.action.to_s.include? action_name and permission.controller == self.class.controller_path
                    }
                }         
                flash[:warning] = "You are not authorized to view the requested page."
                request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to :action => "index", :controller => "site")

                return false
            end
            session["permission_" + action_name + "_" + controller_name] = true
        end
    end

    # Check if user is authenticated, redirecting to the site index if not. Used for simple protection. Otherwise, use Guest role and check_authorization.
    def check_authentication
        unless logged_in?
          flash[:warning] = "You must be logged in to view the requested page."
          request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to :action => "index", :controller => "site")
          return false
        end
    end
    
    # Check if a value has been passed for a negative captcha field named "email_auth", redirecting if a value is found
    def check_negative_captcha
        if not params[:email_auth].blank?
            flash[:warning] = "You appear to be a SPAM bot, and cannot submit to the requested page."
            redirect_to site_index_path
        end
    end
    
    def belongs_to_role?(requested_role)        
        session["role_" + requested_role.underscore] ||= false
        
        unless session["role_" + requested_role.underscore]
            if logged_in?  
                if (current_user.roles.detect{|role| role.name == requested_role}) != nil
                    session["role_" + requested_role.underscore] = true 
                end
            end
        end
        
        session["role_" + requested_role.underscore]
    end
    
    def has_permission?(requested_permission)
        session["permission_" + requested_permission.underscore] ||= false
      
        unless session["permission_" + requested_permission.underscore]
            if logged_in?  
                unless current_user.roles.detect { |role|
                    role.permissions.detect { |permission|
                        session["permission_" + requested_permission.underscore] = true if permission.name == requested_permission
                        }
                    }
                end
            end
        end
        
        session["permission_" + requested_permission.underscore]      
      
    end
    
    # Cache requested URL (e.g. for use with :redirect_to_forwarding_url)
    def cache_request_uri
        session[:protected_page] = request.request_uri
    end
    
    def cache_controller_name
        session[:controller_name] = controller_name
    end
    
    def cache_action_name
        session[:action_name] = action_name
    end

    # Returns true if a parameter matching the given symbol was posted
    def param_posted?(symbol)
        request.post? and (not params[symbol].blank?)
    end

    # Redirect to the previously requested URL (if present)
    def redirect_to_forwarding_url(controller="site",action="index")
        if (redirect_url = session[:protected_page])
            session[:protected_page] = nil
            redirect_to redirect_url
        else
            redirect_to :action => action, :controller => controller
        end
    end
    
    def current_user
        if logged_in?
            @current_user ||= User.find_by_id(session[:user_id]) 
        end
    end
        
    def logged_in?
        not session[:user_id].nil?
    end
     
    def is_admin?
        (not session[:user_id].nil?) and belongs_to_role?('Administrator')
    end
    
    def show_user_ip?
        logged_in? and (has_permission?("Edit Users") or belongs_to_role?("Moderator"))
    end
    
    def set_page_title(txt)
        @title = ConfigurationSetting.get_setting( 'SiteTitle' ) + " | " + txt
    end
	
	# Simple nterface for controllers handling polymorphic actions that are accessed under the context of the parent, and need a common 
	# variable/api/interface/whatever. Call polymorph_parent either as a getter - blah=polymorph_parent - or a setter - ploymorph_parent(blah),
	# which is only as confusing as your understanding of the word "ploymorph". 
	def polymorph_parent(parent=nil)
		@parent ||= parent
		return @parent
	end
    
    private
    
    def update_session_timestamp
        return unless logged_in?
        
        if session[:session_timestamp].nil? or session[:session_timestamp] <= 1.minutes.ago
            session[:session_timestamp] = Time.now
            session.model.update_attribute(:user_id, session[:user_id])
        end
    end
    
    def log_page_views
        return unless ConfigurationSetting.get_setting_to_bool('LogPageViews')
        
        AuditLog.create do |l|  
            l.user_id = logged_in? ? current_user.id : nil
            l.username = logged_in? ? current_user.username : nil
            l.primary_key = params[:id]
            l.ip_address = request.remote_ip
            l.controller = controller_name
            l.action = action_name
            l.event = "viewed page"
        end
    end
end
