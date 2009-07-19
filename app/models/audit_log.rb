class AuditLog < ActiveRecord::Base
    belongs_to    :user
    
    named_scope   :with_ordered,          :order => 'audit_logs.created_at DESC'
    named_scope   :with_user,             :include => :user
    named_scope   :group_by_ip_and_user,  :group => 'ip_address,user_id'
    
    named_scope   :having_multiples,      :group => 'ip_address,user_id HAVING count(user_id) > 1'
  
    class << self
        def find_filtered_audit_logs(users=nil,ips=nil,log_event=nil,log_action=nil,start_date=nil,end_date=nil,sort=nil)
            conditions = Array.new
            users = users.split().map { |un| "'" + un.strip + "'" }.join(",") unless users.blank?
            ips = ips.split().map { |ip| "'" + ip.strip + "'" }.join(",") unless ips.blank?

            if not start_date.blank?
                start_date = Time.parse(start_date).strftime('%Y-%m-%d')
                conditions << "created_at >= :start_date" 
            end
            if not end_date.blank?
                end_date = Time.parse(end_date).strftime('%Y-%m-%d')
                conditions << "created_at <= :end_date"
            end

            # Must manually compose an IN clause with strings and perform the sql sanitization 
            conditions << "(audit_logs.username in (#{users.gsub("'","\'")}) or audit_logs.user_id in (:users))" unless users.blank?
            conditions << "audit_logs.ip_address in (#{ips.gsub("'","\'")})" unless ips.blank?

            conditions << "event = :log_event" unless log_event.blank?
            conditions << "concat(controller,'+',action) = :log_action" unless log_action.blank?
            AuditLog.with_user.find(:all, :conditions =>[conditions.join(" and "), { :users => users, :ips => ips, :log_event => log_event, :log_action => log_action, :start_date => start_date, :end_date => end_date}], :order => "audit_logs." << (sort||='created_at desc'))
        end
        
        def find_used_ip_addresses(query,sort='username',range='year')
            conditions = Array.new
            
            days = case range
               when "day"     then 1
               when "week"    then 7
               when "30 days" then 30
               when "90 days" then 90
               when "year"    then 365
            end
            days_ago = "#{Time.now.advance(:days => (-days)).strftime('%Y-%m-%d')}"
            
            conditions << "username LIKE :query OR ip_address LIKE :query" unless query.blank?
            conditions << "created_at >= :days_ago"
          
            AuditLog.group_by_ip_and_user.find(:all, :conditions => [conditions.join(" and "), {:days_ago => days_ago, :query => "#{query}%"}], :order => sort)
        end
        
        def find_multiple_users
            AuditLog.having_multiples.with_ordered.find(:all)
        end

        def distinct_events
            AuditLog.find(:all, :order => 'audit_logs.event', :group => :event).collect {|l| [ l.event ] }
        end

        def distinct_pages
            AuditLog.find(:all, :order => 'audit_logs.controller, audit_logs.action', :group => 'controller,action').collect {|l| [ l.controller + '+' + l.action ] }
        end
        
        def user_last_seen(user_id)
            AuditLog.maximum(:created_at, :conditions => ["user_id = ?", user_id])
        end
        
        def ip_address_last_seen(ip_address)
            AuditLog.maximum(:created_at, :conditions => ["ip_address = ?", ip_address])
        end
        
        def ip_address_first_seen(ip_address)
            AuditLog.minimum(:created_at, :conditions => ["ip_address = ?", ip_address])
        end
    end
end
