class CreateAccountStatuses < ActiveRecord::Migration
	def self.up
		create_table :account_statuses, :force => true do |t|
			t.string  :name,         :null => false
			t.string  :description
			t.boolean :active,       :default => 0    
		end

		AccountStatus.create(:name=>"Pending",:description=>'User has registered with the system, but has not been approved for account activation yet.',:active=>0)
		AccountStatus.create(:name=>"Active",:description=>'User is registered, authenticated, and active.',:active=>1)
		AccountStatus.create(:name=>"Rejected",:description=>'User registration request was rejected.',:active=>0)
		AccountStatus.create(:name=>"Suspended",:description=>'User is active but momentarily suspended.',:active=>1)
		AccountStatus.create(:name=>"Closed",:description=>'User has closed account and is no longer active.',:active=>0)
		AccountStatus.create(:name=>"Terminated",:description=>'User has been forcefully banned from the system.',:active=>0)
	end

	def self.down
		drop_table :account_statuses 
	end
end
