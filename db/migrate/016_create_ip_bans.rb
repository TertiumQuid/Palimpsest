class CreateIpBans < ActiveRecord::Migration
  def self.up
      create_table :ip_bans, :force => true do |t|
        t.string    :ip_address
        t.string    :reason,          :limit => 1024

        t.timestamps
      end
  end

  def self.down
      drop_table :ip_bans
  end
end      