class SocialBookmark < ActiveRecord::Base
    attr_accessible   :name, :url, :active, :icon
    
    validates_presence_of     :name, :url
    validates_length_of       :name,      :within => 3..32
    
    has_attached_file                 :icon, 
                                      :default_style => :bookmarklet,
                                      :path => ":rails_root/public/images/icons/bookmarklets/:style_:basename.:extension", 
                                      :url => "/images/icons/bookmarklets/:style_:basename.:extension",
                                      :default_url => "/images/icons/bookmark.gif", 
                                      :styles => { :bookmarklet => "16x16>" }
    validates_attachment_size         :icon, :in => 0.kilobytes...150.kilobytes
    validates_attachment_content_type :icon, { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/pjpeg'] }
    
    named_scope :with_ordered, :order => 'social_bookmarks.name ASC'
    named_scope :with_active, :conditions =>["social_bookmarks.active=1"]        
end
