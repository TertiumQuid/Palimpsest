class ConfigurationSetting < ActiveRecord::Base
    validates_uniqueness_of   :key    
    validates_presence_of     :key, :value
    
    class << self
        def get_setting(setting)
            val = ConfigurationSetting.find_by_key(setting)
            return val.value
        end

        def get_setting_to_bool(setting)
            val = ConfigurationSetting.find_by_key(setting)
            return val.value.downcase == "true"
        end
    end
end
