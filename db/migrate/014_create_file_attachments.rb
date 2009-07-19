class CreateFileAttachments < ActiveRecord::Migration
  def self.up
      create_table :file_attachments, :force => true do |t|
        t.integer   :parent_id
        t.string    :parent_type,   :limit => 64

        t.string    :attachment_file_name
        t.string    :attachment_content_type
        t.integer   :attachment_file_size  

        t.timestamps
      end
	  
	  add_index :file_attachments, :parent_id
  end

  def self.down
      drop_table :attachments
  end
end
