class AccountStatus < ActiveRecord::Base
    class << self
		def all_cached
			Rails.cache.fetch('AccountStatus.all') { all }
		end
		
        def options_for_select
			all_cached.collect {|s| [ s.name, s.id ] }
        end
    end
end
