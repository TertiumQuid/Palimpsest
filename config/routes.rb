ActionController::Routing::Routes.draw do |map|
  def map.controller_actions(controller, actions)
      actions.each do |action|
          self.send("#{controller}_#{action}", "#{controller}/#{action}", :controller => controller, :action => action)
      end
  end
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.root :controller => "site"
  
  map.controller_actions 'site', %w[index about privacy tos registration_success contact]
  map.controller_actions 'admin', %w[configuration configure exception_logs audit_logs file_storage ip_addresses]
    
  map.resources :users, :collection => { :dashboard => :get, :register => :get }
  
  map.with_options :controller => 'users' do |user|
    user.login    'login',  :action => 'login'
    user.logout   'logout', :action => 'logout'
  end
  map.user_forum_posts 'users/:user_id/forum_posts', :controller => 'forum_posts', :action => 'show_user_posts'
  
  map.resources :forums do |forums|
      forums.resources :forum_topics
  end
  
  map.resources :forum_topics do |forum_topics|
      forum_topics.resources :forum_posts
  end

  map.resources :forum_posts
  map.resources :social_bookmarks
  
  map.news_archives 'news_archives/:year/:month/:day',	:controller => 'news_articles', :month => nil, :day => nil, :requirements => { :year => /\d{4}/ }
  map.news_tag		'news_tags/:tag',					:controller => 'news_articles', :action => 'index'
  map.news_category 'news_categories/:category',		:controller => 'news_articles', :action => 'index'  
  map.resources :news_articles
  
  map.resources :comments, :member => { :approve => :post }
    
  map.private_messages_send 'private_messages/new/:recipient_list', :controller => 'private_messages', :action => 'new'
  map.resources :private_messages

  map.file_handler  'file_attachments/:content_type/:parent_id/:id', :controller => 'file_attachments', :action => 'show'
  
  map.connect ':controller/:site'
end
