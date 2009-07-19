# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    include TagsHelper
    def tab_link(text, url, id=nil)
        url << "/" + id.to_s if id 
        if current_controller?(url) and current_action?(url)
            "<li class='current_page_item'>#{link_to "<span>" + text + "</span>", url}</li>"
        else
            "<li>#{link_to "<span>" + text + "</span>", url}</li>"
        end
    end
    
    def tab_link_controller(text, url, controllers, exclusions=nil)
        if current_controller?(nil,controllers) and (exclusions.nil? or not exclusions.include?(action_name))
            "<li class='current_page_item'>#{link_to "<span>" + text + "</span>", url}</li>"
        else
            "<li>#{link_to "<span>" + text + "</span>", url}</li>"
        end
    end
    
    def sub_tab_link(text, url, controllers=nil)
        if (current_controller?(url) and current_action? url) or (controllers and current_controller?(nil,controllers))
            link_to "<span>" + text + "</span>", url, {:class => "selected" }
        else
            link_to "<span>" + text + "</span>", url
        end
    end
    
    def user_link(user_id,username)
        if (user_id ||= 0) > 0
             link_to h(username||="N/A"), user_url(user_id)
        else
             "anonymous"
        end      
    end
    
    def user_status_link(user)
        if user
            # Only authenticated users can see status links
            if logged_in?
                render(:partial => "/users/session_status_icon", :locals =>  { :status => user.session_status }) << link_to(h(user.username), user_url(user.id))
            else
                h(user.username)
            end
        else
             "anonymous"
        end      
    end
    
    def minor_edit_link(url)
        link_to image_tag(image_path("/images/icons/note_edit.gif"), :alt => "edit", :title => "edit") + "edit", url
    end
    
    def minor_edit_text_link(url,txt,css_class="",method=:post,onclick=nil)
        link_to "[ " + txt + " ]", url, :class => "minor_edit_text_link " + css_class, :method => method, :onclick => onclick
    end
    
    def minor_delete_text_link(url,name,css_class="")
        link_to "[ Delete ]", url, :method => :delete, :class => "minor_edit_text_link " + css_class, :confirm => "Delete this #{name}?  Are you sure?"
    end
    
    def add_attachment_link(name,css_class="")
        link_to_function name, :class => "minor_edit_text_link " + css_class do |page|
            page.insert_html :bottom, :attachments, :partial => 'attachment', :object => FileAttachment.new(:attachment_file_name=> "blah")
        end
    end
    
    def view_attachment_link(attachment)
        link_to image_tag("icons/attach.gif",:alt=>attachment.attachment_file_name) + 
            attachment.attachment_file_name,
            file_handler_path(attachment.parent_type,attachment.parent_id,attachment.id),
            :target=>"_blank"
    end
        
    # Determines if the given url matches the current page controller, based on whether the url contains the controller name as its top level element
    def current_controller?(url, controllers=nil)
        # first check for special case of site index
        return true if url == site_index_path and controller_name == "site"
      
        # if a url string was passed, check against controller, else assume an array of controller names was passed so check the list
        if controllers
          return controllers.include?(controller_name) 
        else
          return url && (url.split('/')[1] == controller_name)
        end
    end
    
    # Determines if the given url matches the current action, based on whether the url contains the action name as its second level element
    def current_action?(url)
        return url.split('/')[2] == action_name
    end
    
    def negative_captcha
        "<span class='email_auth'>Leave this field blank: <input type='text' name='email_auth' value='' /></span>"
    end
    
    # Calls javascript include for tinymce scripts
    def use_tinymce
        @content_for_tinymce = "" 
        content_for :tinymce do
            javascript_include_tag "tiny_mce/tiny_mce"
        end
        @content_for_tinymce_init = "" 
        content_for :tinymce_init do
            javascript_include_tag "mce_editor"
        end
    end
    
    # Calls javascript include for boxover scripts
    def use_boxover
        content_for :boxover do  
            javascript_include_tag "boxover"
        end
    end
    
    def boxover(header,body,singleclickstop="on")
        "title=\"header=[#{header}] body=[#{body}] singleclickstop=[#{singleclickstop}] cssheader=[boxover_header] cssbody=[boxover_body]\""
    end
end
