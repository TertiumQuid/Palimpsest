class CreateSocialBookmarks < ActiveRecord::Migration
  def self.up
      create_table :social_bookmarks, :force => true do |t|
        t.string    :name,            :limit => 32
        t.string    :url,             :limit => 512
        t.boolean   :active,          :default => 1

        t.string    :icon_file_name
        t.string    :icon_content_type
        t.integer   :icon_file_size  

        t.timestamps
      end
      
      delicious = SocialBookmark.create(:name=>"del.icio.us", :url=>"http://del.icio.us/post?url={{U}}&amp;title={{T}}")
      delicious.icon_file_name="delicious.gif"
      delicious.icon_file_size=82 
      delicious.icon_content_type="image/gif"
      delicious.save
      
      digg = SocialBookmark.create(:name=>"digg", :url=>"http://digg.com/submit?phase=2&amp;url={{U}}&amp;title={{T}}")
      digg.icon_file_name="digg.gif"
      digg.icon_file_size=245 
      digg.icon_content_type="image/gif"
      digg.save
      
      reddit = SocialBookmark.create(:name=>"reddit", :url=>"http://reddit.com/submit?url={{U}}&amp;title={{T}}")
      reddit.icon_file_name="reddit.gif"
      reddit.icon_file_size=589
      reddit.icon_content_type="image/gif"
      reddit.save
      
      furl = SocialBookmark.create(:name=>"furl", :url=>"http://www.furl.net/storeIt.jsp?u={{U}}&amp;t={{T}}")
      furl.icon_file_name="furl.gif"
      furl.icon_file_size=617
      furl.icon_content_type="image/gif"
      furl.save
      
      blogmarks = SocialBookmark.create(:name=>"blogmarks", :url=>"http://blogmarks.net/my/new.php?mini=1&amp;simple=1&amp;url={{U}}&amp;title={{T}}")
      blogmarks.icon_file_name="blogmarks.gif"
      blogmarks.icon_file_size=208
      blogmarks.icon_content_type="image/gif"
      blogmarks.save    
      
      simpy = SocialBookmark.create(:name=>"simpy", :url=>"http://www.simpy.com/simpy/LinkAdd.do?href={{U}}&amp;title={{T}}")
      simpy.icon_file_name="simpy.gif"
      simpy.icon_file_size=570
      simpy.icon_content_type="image/gif"
      simpy.save
      
      google = SocialBookmark.create(:name=>"google", :url=>"http://www.google.com/bookmarks/mark?op=edit&amp;output=popup&amp;bkmk={{U}}&amp;title={{T}}")
      google.icon_file_name="google.gif"
      google.icon_file_size=1079
      google.icon_content_type="image/gif"
      google.save
      
      yahoo = SocialBookmark.create(:name=>"yahoo", :url=>"http://myweb2.search.yahoo.com/myresults/bookmarklet?u={{U}}&amp;t={{T}}")
      yahoo.icon_file_name="yahoo.gif"
      yahoo.icon_file_size=623
      yahoo.icon_content_type="image/gif"
      yahoo.save
      
      netvouz = SocialBookmark.create(:name=>"netvouz", :url=>"http://www.netvouz.com/action/submitBookmark?url={{U}}&amp;title={{T}}&amp;popup=no")
      netvouz.icon_file_name="netvouz.gif"
      netvouz.icon_file_size=99
      netvouz.icon_content_type="netvouz/gif"
      netvouz.save  
      
      stumbleupon = SocialBookmark.create(:name=>"stumbleupon", :url=>"http://www.stumbleupon.com/submit?url={{U}}%26title%3D{{T}}")
      stumbleupon.icon_file_name="stumbleupon.gif"
      stumbleupon.icon_file_size=1073
      stumbleupon.icon_content_type="image/gif"
      stumbleupon.save
  end

  def self.down
      drop_table :social_bookmarks
  end
end
