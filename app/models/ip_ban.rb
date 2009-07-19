class IpBan < ActiveRecord::Base   
    class << self
        def find_ip_addresses(query,sort='ip_address')
            conditions = Array.new
            conditions << "ip_address LIKE :query" unless query.blank?
          
            IpBan.find(:all, :conditions => [conditions.join(" and "), {:query => "#{query}%"}], :order => sort)
        end
    end
end
