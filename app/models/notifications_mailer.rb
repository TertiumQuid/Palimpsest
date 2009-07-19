class NotificationsMailer < ActionMailer::Base
    include ActionController::UrlWriter
    default_url_options[:host] = 'localhost'
    
    def register(user, ip_address=nil, sent_at=Time.now)
      
      subject    ConfigurationSetting.get_setting("SiteTitle") + " Registration"
      recipients user.email
      from       ConfigurationSetting.get_setting("SiteTitle") + "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      sent_on    sent_at

      body       :user => user, 
                 :require_registration_approval => ConfigurationSetting.get_setting_to_bool("RequireRegistrationApproval"),
                 :site_title => ConfigurationSetting.get_setting("SiteTitle"),
                 :site_email => ConfigurationSetting.get_setting("SiteEmail"),
                 :ip_address => ip_address,
                 :url => ConfigurationSetting.get_setting("SiteURL")
    end

    def forgot_password(user, ip_address=nil, sent_at=Time.now)
      
      subject    ConfigurationSetting.get_setting("SiteTitle") + " Forgot Login Details"
      recipients user.email
      from       ConfigurationSetting.get_setting("SiteTitle") + "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      sent_on    sent_at

      body       :user => user, 
                 :site_title => ConfigurationSetting.get_setting("SiteTitle"),
                 :site_email => ConfigurationSetting.get_setting("SiteEmail"),
                 :ip_address => ip_address,
                 :url => ConfigurationSetting.get_setting("SiteURL")
    end

    def registration_rejected(user, sent_at=Time.now)
      subject    ConfigurationSetting.get_setting("SiteTitle") + " Registration Rejected"
      recipients user.email
      from       ConfigurationSetting.get_setting("SiteTitle") + "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      sent_on    sent_at

      body       :user => user, 
                 :site_title => ConfigurationSetting.get_setting("SiteTitle"),
                 :site_email => ConfigurationSetting.get_setting("SiteEmail")
    end

    def registration_approved(user, sent_at=Time.now)
      subject    ConfigurationSetting.get_setting("SiteTitle") + " Registration Approved"
      recipients user.email
      from       ConfigurationSetting.get_setting("SiteTitle") + "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      sent_on    sent_at

      body       :user => user, 
                 :site_title => ConfigurationSetting.get_setting("SiteTitle"),
                 :site_email => ConfigurationSetting.get_setting("SiteEmail"),
                 :url => ConfigurationSetting.get_setting("SiteURL")
    end

    def contact_us(email, name, subject, body_text, sent_at=Time.now)
      subject    ConfigurationSetting.get_setting("SiteTitle") + " Form Mail: " + subject
      recipients "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      from       name + "<" + email +  ">"
      sent_on    sent_at

      body       :body_text => body_text
    end

    def private_message(private_message,recipient,sent_at=Time.now)
      subject     ConfigurationSetting.get_setting("SiteTitle") + " Message: " + private_message.subject
      recipients  recipient.username + "<" + recipient.email + ">"
      from        private_message.user.username + "<" + ConfigurationSetting.get_setting("SiteEmail") +  ">"
      sent_on     sent_at
      
      body       :private_message => private_message, 
                 :site_title => ConfigurationSetting.get_setting("SiteTitle"),
                 :url => ConfigurationSetting.get_setting("SiteURL"),
                 :quote_pm => ConfigurationSetting.get_setting_to_bool("QuotePrivateMessageInEmail"),
                 :recipient => recipient
    end
end
