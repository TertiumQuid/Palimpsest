class CreateAuditLogs < ActiveRecord::Migration
  def self.up
    create_table :audit_logs, :force => true do |t|
      t.integer   :user_id
      t.integer   :primary_key
      t.string    :ip_address
      t.string    :username     
      t.string    :controller
      t.string    :action
      t.string    :event
      
      t.timestamps
    end
  end

  def self.down
    drop_table :audit_logs
  end
end
