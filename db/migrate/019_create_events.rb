class CreateEvents < ActiveRecord::Migration
	def self.up
		create_table :events, :force => true do |t|
			t.string	:name,				:null => false
			t.string	:description
			t.integer	:event_category_id
			t.boolean	:active,			:default => 0    
			t.datetime	:scheduled_date,	:null => false
			
			t.timestamps
		end
		
		create_table :event_categories, :force => true do |t|
			t.string    :title,                   :limit => 64
			t.string    :color,                   :limit => 32
		end
	end
	
	def self.down
		drop_table :events 
		drop_table :event_categories 
	end
end
