class SiteController < ApplicationController
  include ApplicationHelper, SocialBookmarksHelper
  
  before_filter   :check_authorization,      :only => [ :configuration, :configure ]
  
  after_filter    :cache_controller_name,    :only => [ :index ]
  after_filter    :cache_action_name,        :only => [ :index ]
  
  def index
      set_page_title "Home"
  end

  def about
      set_page_title "About"
  end

  def privacy
      set_page_title "Privacy Policy"
  end

  def tos
      set_page_title "Terms of Service"
  end

  def contact
      set_page_title "Contact Us"
      
      @errors = []
      if param_posted? :email
          # validate email form values
          @errors << "Subject missing" if params[:subject].blank? 
          @errors << "Body missing" if params[:body].blank? 
          email_expression = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
          if params[:email].blank? 
              @errors << "Email Address missing" 
          elsif not email_expression.match(params[:email])
              @errors << "Invalid Email Address format" 
          end
          
          # send contact email
          if @errors.empty?
              spawn do
                  NotificationsMailer.deliver_contact_us(params[:email],params[:name],params[:subject],params[:body])
              end
              flash[:notice] = "Email sent! Thanks for your interest in " + ConfigurationSetting.get_setting("SiteTitle") + "." 
              redirect_to site_index_path
          end
      end
  end

  def registration_success
      # Registered users have no reason to view this page
      redirect_to site_index_path if logged_in? or not ConfigurationSetting.get_setting_to_bool("RequireRegistrationApproval") 
    
      set_page_title "Registration Success"
  end
end
