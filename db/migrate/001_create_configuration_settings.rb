class CreateConfigurationSettings < ActiveRecord::Migration
  def self.up
    create_table :configuration_settings, :force => true do |t|
      t.string :key,          :null => false
      t.string :value,        :null => false,   :limit => 1024
      t.string :data_type
      
      t.timestamps
    end    
	
    add_index :configuration_settings, :key
    
    ConfigurationSetting.create(:key=>"SiteTitle",:value=>'Palimpsest',:data_type=>'string')
    ConfigurationSetting.create(:key=>"SiteSlogan",:value=>'Scrape it, write it, run it!',:data_type=>'string')
    ConfigurationSetting.create(:key=>"SiteEmail",:value=>'palimpsest@example.com',:data_type=>'string')
    ConfigurationSetting.create(:key=>"SiteURL",:value=>'www.example.com',:data_type=>'string')
    ConfigurationSetting.create(:key=>"WebAnalyticsTrackingCode",:value=>'<!-- -->',:data_type=>'string')
    ConfigurationSetting.create(:key=>"Salt",:value=>'salt123',:data_type=>'string')
    ConfigurationSetting.create(:key=>"DefaultUserRole",:value=>'User',:data_type=>'string')
    ConfigurationSetting.create(:key=>"AllowRegistration",:value=>'true',:data_type=>'boolean')
    ConfigurationSetting.create(:key=>"RequireRegistrationApproval",:value=>'true',:data_type=>'boolean')
    ConfigurationSetting.create(:key=>"AllowAnonymousPosters",:value=>'true',:data_type=>'boolean')
    ConfigurationSetting.create(:key=>"LogPageViews",:value=>'true',:data_type=>'boolean')
    
    ConfigurationSetting.create(:key=>"PrivateMessageRecipientLimit",:value=>'12',:data_type=>'integer')
    ConfigurationSetting.create(:key=>"DailyPrivateMessageLimit",:value=>'25',:data_type=>'integer')
    ConfigurationSetting.create(:key=>"EmailPrivateMessageNotices",:value=>'true',:data_type=>'boolean')
    ConfigurationSetting.create(:key=>"QuotePrivateMessageInEmail",:value=>'true',:data_type=>'boolean')
    
    ConfigurationSetting.create(:key=>"UseSocialBookmarks",:value=>'true',:data_type=>'boolean')
  end

  def self.down
    drop_table :configuration_settings
  end
end
