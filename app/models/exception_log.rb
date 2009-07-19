class ExceptionLog < ActiveRecord::Base
    belongs_to    :user, :counter_cache => true, :foreign_key => "user_id"
    
    named_scope :with_ordered, :order => 'exception_logs.created_at DESC'
    
    class << self
        def find_filtered_exception_logs(users=nil,ips=nil,exception_type=nil,log_action=nil,start_date=nil,end_date=nil)
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
            conditions << "(exception_logs.username in (#{users.gsub("'","\'")}) or exception_logs.user_id in (:users))" unless users.blank?
            conditions << "exception_logs.ip_address in (#{ips.gsub("'","\'")})" unless ips.blank?

            conditions << "exception_type = :exception_type" if not exception_type.blank?
            conditions << "concat(controller,'+',action) = :log_action" if not log_action.blank?

            ExceptionLog.find(:all, :include => [:user], :conditions =>[conditions.join(" and "), { :users => users, :ips => ips, :exception_type => exception_type, :log_action => log_action, :start_date => start_date, :end_date => end_date}])
        end

        def distinct_exception_types
            ExceptionLog.find(:all, :order => 'exception_logs.exception_type', :group => :exception_type).collect {|l| [ CGI::escapeHTML(l.exception_type) ] }
        end

        def distinct_pages
            ExceptionLog.find(:all, :conditions =>["exception_logs.controller is not null"], :order => 'exception_logs.controller, exception_logs.action', :group => 'controller,action').collect {|l| [ CGI::escapeHTML(l.controller + '+' + l.action) ] }
        end
    end
end
