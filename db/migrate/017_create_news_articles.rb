class CreateNewsArticles < ActiveRecord::Migration
  def self.up
      create_table :news_articles, :force => true do |t|
        t.integer   :user_id,				  :null => false
        t.integer   :news_article_category_id
        
        t.integer   :comment_governance_id,   :null => false, :default => 1        
        t.integer   :comments_count,          :default => 0
        t.boolean   :moderate_comments,       :default => true
      
        t.string    :title,                   :limit => 128
        t.string    :summary
        t.text      :body,                    :null => false

        t.string    :cached_tag_list,         :limit => 1024

        t.timestamps
      end

      create_table :news_article_categories,  :force => true do |t|
        t.string    :title,                   :limit => 64
        t.integer   :news_articles_count,     :default => 0
      end
	  
	  add_index :news_articles, :news_article_category_id
	  add_index :news_articles, :created_at

      NewsArticleCategory.create(:title=>"Palimpsest")    
      NewsArticleCategory.create(:title=>"Rails") 
      
      article = NewsArticle.new(
          :title=>"Website Launched!", 
          :summary=>"Website goes online and first article posted to test the news engine!",
          :body=>"<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Phasellus dapibus sem. Mauris non diam sit amet arcu consequat vulputate. Etiam massa. Nullam sed erat id risus molestie ultricies. Nulla egestas fermentum est. Vestibulum erat urna, tincidunt sed, ornare in, tristique eget, tellus. Quisque fermentum. In hac habitasse platea dictumst. Phasellus semper, augue quis hendrerit lobortis, quam massa aliquam ligula, eget euismod risus orci ut nulla. Aliquam non diam. Donec purus augue, pulvinar a, congue in, tempus et, urna. Fusce aliquam molestie arcu. </p>",
          :comment_governance_id=>1,
          :news_article_category_id=>1) do |a|
              a.user_id = 1
              a.tag_list = "Site,Test,News"
          end
      article.save    
  end

  def self.down
    drop_table :news_articles
    drop_table :news_article_categories
  end
end
