class CreateExceptionLogs < ActiveRecord::Migration
  def self.up
    create_table :exception_logs, :force => true do |t|
      t.integer   :user_id
      t.string    :username
      t.string    :ip_address
      t.string    :controller
      t.string    :action
      t.string    :exception_type
      t.string    :host
      t.text      :message
      t.text      :backtrace
      t.text      :params
      
      t.timestamps
    end
	
    add_index :exception_logs, :username, :id_address
  end

  def self.down
    drop_table :exception_logs
  end
end
