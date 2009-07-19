class FileAttachment < ActiveRecord::Base
    belongs_to    :parent,  :polymorphic => true
    
    has_attached_file             :attachment, 
                                  :path => ":rails_root/protected/attachments/:id/:style/:basename.:extension",
                                  :url => "/attachments/:id/:style/:basename.:extension"
                
    # If an attachment record is destroyed, delete associated hard files
    after_destroy { |attachment| Dir.glob("protected/attachments/#{attachment.parent_type}/#{attachment.id}/*").each{ |f| FileUtils.rm_rf(f) }}
  
    validates_attachment_size     :attachment, :in => 0.megabytes...1.megabytes
    validates_presence_of         :attachment
  
    class << self
        # Deletes all attachment associations and deletes all hard files
        def purge_attachments!
            FileAttachment.all.each {|file| file.destroy }
            Dir.glob("protected/attachments/*").each{ |f| FileUtils.rm_rf(f) }
        end
    end
end
