class UsersController < ApplicationController
  include ApplicationHelper
  require 'digest/sha1'
  
  helper_method   :can_edit_user?
  
  before_filter   :prepare_parameters,          :only => [ :show, :edit ]
  
  before_filter   :dnsbl_check,                 :only => [ :create ]
  before_filter   :check_authentication,        :only => [ :index, :show ]
  before_filter   :check_allow_edit,            :only => [ :edit, :update, :destroy ]   
  before_filter   :check_allow_registration,    :only => [ :register, :create ]
  before_filter   :check_allow_public,          :only => [ :show ]
  
  after_filter    :cache_action_name,        :only => [ :new, :edit, :register ]
  
  def index
      set_page_title "User Directory"
      
      # prohibit restricted users from viewing anything but other active users
      if params[:account_status_id] and has_permission?("Edit Users")
          account_status_id = params[:account_status_id] 
      else
          account_status_id = 2
      end
          
      letter = params[:letter]
      
      @users = User.find_filtered_users(letter,account_status_id).paginate :per_page => 25, :page => params[:page]
      @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
      
      # If an AJAX sort/filter/paginate request was called from the user display...
      render(:partial => "/users/user_table", :layout => false) if request.xhr?    
  end
  
  def show       
      set_page_title "User Profile - " + @user.display_name
  end 
  
  def new
      set_page_title "Create User"
      
      @user = User.new
  end
  
  def create
      @user = User.new(params[:user])
      @user.display_name = @user.username
      
      # if a new user is registering, associate their ip with their user accont
      @user.ip_address = request.remote_ip if not logged_in?
      
      @user.account_status = ConfigurationSetting.get_setting_to_bool("RequireRegistrationApproval") ? AccountStatus.find_by_name("Active") : AccountStatus.find_by_name("Pending")
      
      if @user.save
          if not logged_in?
              # User has registered for the first time (i.e. user is not being created from within the system) so send notification email
              spawn do
                  NotificationsMailer.deliver_register(@user,request.remote_ip)
              end
              if @user.account_status
                  @user.login!(session)
                  if @user.remember_me == "1"
                      cookies[:remember_me] = { :value => "1", :expires => 10.years.from_now }
                  end
                  flash[:notice] = "Account for user #{@user.username} created"
                  redirect_to dashboard_users_path                        
              else
                  flash[:notice] = "Account for user #{@user.username} created. Check your email for details."
                  redirect_to site_registration_success_path
              end
          end

          session[:action_name] = nil
      else
          @user.clear_password!
          render :action => session[:action_name] 
      end
  end
  
  def edit
      set_page_title "Edit User - " + @user.display_name
  end
  
  def update  
      @user = User.find(params[:id])   
      
      # Avatars must be deleted separate from the main user model due to how nil checks won't acknowledge empty input files. Deletion is instead acknowledged by setting a form flag
      unless params[:delete_avatar_flag].blank?
          @user.update_attribute("avatar", nil)
          
          flash[:notice] = "Avatar image deleted."
          redirect_to edit_user_path(@user) and return
      end
    
      old_account_status = @user.account_status
      if @user.update_attributes(params[:user]) and (not has_permission?("Edit Users") or @user.is_admin? or @user.update_attribute(:account_status_id, params[:account_status_id]) )
          # If the user's account status has been updated, send a notification
          if (old_account_status.name == "Pending" and not @user.account_status_id == old_account_status.id)
              spawn do
                  if AccountStatus.find(@user.account_status_id).active
                      NotificationsMailer.deliver_registration_approved(@user)
                  else
                      NotificationsMailer.deliver_registration_rejected(@user)
                  end
              end
          end
          flash[:notice] = "User profile updated."
          redirect_to user_path(@user) and return
      else
          render :action => session[:action_name]    
      end
  end
  
  def destroy    
  end
  
  def register
      set_page_title "Register"
      
      @user ||= User.new
  end
  
  def dashboard
      @user = current_user
      
      set_page_title CGI.escapeHTML(current_user.display_name) + "'s Dashboard"   
  end
  
  def login
      @user = User.new(params[:login])
      user = User.find_by_login( @user.username,@user.password)
      
      if user and user.account_status.active 
          reset_session
          user.login!(session)
          
          # if a new user is logging in for the first time, associate their ip with their user accont
          user.update_attribute("ip_address", request.remote_ip) if user.ip_address.nil?
      
          if @user.remember_me == "1"
              user.remember!(cookies)
          else
              user.forget!(cookies)
          end
          
          flash[:notice] = "User #{user.username} logged in!"
          
          redirect_to_forwarding_url "users","dashboard"
      elsif user and not user.account_status.active
          @user.clear_password!
          
          flash[:warning] = "Account is inactive"
          redirect_to :back
      else
          @user.clear_password!
          
          flash[:warning] = "Invalid username/password combination"
          redirect_to :back
      end
  end
  
  def logout
      User.logout!(session, cookies)
      
      reset_session
      flash[:notice] = "Logged out."      
      redirect_to site_index_path
  end
  
  protected
  
  def prepare_parameters
       @user = (User.find(params[:id]) or current_user)
  end
  
  def can_edit_user?(user)
      params[:id] == session[:user_id].to_s or (has_permission?("Edit Users") and not user.is_admin?)
  end
  
  private 
  
  def check_allow_registration
      unless (not logged_in? and ConfigurationSetting.get_setting_to_bool( 'AllowRegistration' )) or has_permission?("Create Users")
          flash[:warning] = "New user registration has been disabled"
          redirect_to request.env["HTTP_REFERER"] ? :back : site_index_path
      end
  end
  
  def check_allow_edit
      unless can_edit_user? User.find(params[:id]) 
          flash[:warning] = "You cannot edit this user"
          redirect_to request.env["HTTP_REFERER"] ? :back : user_path(params[:id]) 
      end
  end
  
  def check_allow_public
      if %w(Pending Rejected).include? @user.account_status.name and not has_permission?("Edit Users") 
          flash[:warning] = "Invalid user"
          redirect_to request.env["HTTP_REFERER"] ? :back : users_path
      end
  end
end
