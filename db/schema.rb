# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 19) do

  create_table "account_statuses", :force => true do |t|
    t.string  "name",        :default => "",    :null => false
    t.string  "description"
    t.boolean "active",      :default => false
  end

  create_table "audit_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "primary_key"
    t.string   "ip_address"
    t.string   "username"
    t.string   "controller"
    t.string   "action"
    t.string   "event"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_governances", :force => true do |t|
    t.string "name",        :default => "", :null => false
    t.string "description"
  end

  create_table "comments", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type", :limit => 64
    t.boolean  "is_approved",               :default => false, :null => false
    t.integer  "user_id"
    t.string   "author"
    t.string   "email"
    t.string   "ip_address"
    t.string   "website_url"
    t.text     "body",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configuration_settings", :force => true do |t|
    t.string   "key",                        :default => "", :null => false
    t.string   "value",      :limit => 1024, :default => "", :null => false
    t.string   "data_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_categories", :force => true do |t|
    t.string "title", :limit => 64
    t.string "color", :limit => 32
  end

  create_table "events", :force => true do |t|
    t.string   "name",              :default => "",    :null => false
    t.string   "description"
    t.integer  "event_category_id"
    t.boolean  "active",            :default => false
    t.datetime "scheduled_date",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exception_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "username"
    t.string   "ip_address"
    t.string   "controller"
    t.string   "action"
    t.string   "exception_type"
    t.string   "host"
    t.text     "message"
    t.text     "backtrace"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_attachments", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type",             :limit => 64
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "forum_topic_id",               :null => false
    t.string   "username",       :limit => 32
    t.string   "subject",        :limit => 32
    t.text     "body",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_topics", :force => true do |t|
    t.integer  "forum_id",                                              :null => false
    t.integer  "user_id"
    t.string   "title",                :limit => 32, :default => "",    :null => false
    t.integer  "views_count",                        :default => 0
    t.integer  "forum_posts_count",                  :default => 0
    t.boolean  "locked",                             :default => false
    t.boolean  "sticky",                             :default => false
    t.datetime "last_replied_at"
    t.integer  "recent_post_id"
    t.integer  "recent_post_user_id"
    t.string   "recent_post_username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", :force => true do |t|
    t.string   "name",               :limit => 32, :default => "", :null => false
    t.string   "description"
    t.integer  "forum_topics_count",               :default => 0
    t.integer  "forum_posts_count",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ip_bans", :force => true do |t|
    t.string   "ip_address"
    t.string   "reason",     :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_article_categories", :force => true do |t|
    t.string  "title",               :limit => 64
    t.integer "news_articles_count",               :default => 0
  end

  create_table "news_articles", :force => true do |t|
    t.integer  "user_id",                                                    :null => false
    t.integer  "news_article_category_id"
    t.integer  "comment_governance_id",                    :default => 1,    :null => false
    t.integer  "comments_count",                           :default => 0
    t.boolean  "moderate_comments",                        :default => true
    t.string   "title",                    :limit => 128
    t.string   "summary"
    t.text     "body",                                                       :null => false
    t.string   "cached_tag_list",          :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.string   "controller",  :default => "", :null => false
    t.string   "action",      :default => "", :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "private_message_recipients", :force => true do |t|
    t.integer "private_message_id"
    t.integer "user_id"
    t.boolean "has_read",           :default => false
    t.boolean "has_deleted",        :default => false
  end

  create_table "private_messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "original_message_id"
    t.string   "username",            :limit => 32
    t.string   "subject",             :limit => 64
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "social_bookmarks", :force => true do |t|
    t.string   "name",              :limit => 32
    t.string   "url",               :limit => 512
    t.boolean  "active",                           :default => true
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.integer  "account_status_id",                  :default => 2,  :null => false
    t.string   "username",             :limit => 32, :default => "", :null => false
    t.string   "display_name",         :limit => 64
    t.string   "email",                              :default => "", :null => false
    t.string   "password",             :limit => 64, :default => "", :null => false
    t.string   "signature"
    t.string   "website_url"
    t.string   "ip_address"
    t.text     "personal_text"
    t.string   "timezone"
    t.string   "authorization_token"
    t.string   "authentication_hash"
    t.datetime "last_login_time"
    t.integer  "forum_posts_count",                  :default => 0
    t.integer  "exception_logs_count",               :default => 0
    t.integer  "news_articles_count",                :default => 0
    t.integer  "comments_count",                     :default => 0
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
