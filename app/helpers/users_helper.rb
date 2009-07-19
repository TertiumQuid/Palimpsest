module UsersHelper
    def account_status_select(selected_value=nil,options={})
        select_tag  'account_status_id', 
                    options_for_select(AccountStatus.options_for_select, 
                    selected = selected_value||=(params[:account_status_id] ? params[:account_status_id].to_i : 2)), 
                    options.merge(:class => 'styled')
    end
end
