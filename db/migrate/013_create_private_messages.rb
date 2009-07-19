class CreatePrivateMessages < ActiveRecord::Migration
	def self.up
		create_table :private_messages, :force => true do |t|
			t.integer   :user_id
			t.integer   :original_message_id
			t.string    :username,            :limit => 32
			t.string    :subject,             :limit => 64
			t.text      :body
			
			t.timestamps
		end
		
		create_table :private_message_recipients, :force => true do |t|
			t.integer   :private_message_id
			t.integer   :user_id
			t.boolean   :has_read,      :default => 0
			t.boolean   :has_deleted,   :default => 0
		end
		
		add_index :private_messages, :user_id
		add_index :private_messages, :original_message_id
		add_index :private_message_recipients, :private_message_id
  end

  def self.down
		drop_table :private_messages
		drop_table :private_message_recipients
  end
end
