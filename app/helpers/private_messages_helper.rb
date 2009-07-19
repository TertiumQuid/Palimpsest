module PrivateMessagesHelper
    def pm_user_display(msg)
        if is_current_user_sender?(msg)
            msg.recipient_users.find(:all,:limit=>3).map{ |user| user_status_link(user)}.join(", ") + (msg.recipient_users.size > 3 ? " (" + (msg.recipient_users.size - 3).to_s + " more)..." : "")
        else
            user_status_link(msg.user)
        end
    end
    
    def pm_reply_to_link(message_id)
        "<a href=\"#reply\" onclick=\"setReplyRecipients('#{message_id}','sender');\"><img src='/images/icons/email_reply.gif' />reply</a>"
    end
    
    def pm_reply_to_all_link(message_id)
        "<a href=\"#reply\" onclick=\"setReplyRecipients('#{message_id}','all');\"><img src='/images/icons/email_reply.gif' />reply to all</a>"
    end
    
    def conversation_status_icon(pm,user_id,viewing_received)
        if viewing_received
            image_tag((pm.has_unread_messages?(user_id) ? "icons/email.gif" : "icons/email_open.gif"), :alt => "sent msg", :class => "left updent5 outdent2")
        else
            image_tag("icons/email_reply.gif", :alt => "sent msg", :class => "left updent5")
        end
    end
    
    def private_messages_send_link(user_id,username,css_class="")
        link_to(image_tag("icons/email_reply.gif",:alt=>"send private message",:class=>"tb3") + " msg", private_messages_send_path(username), :class => "right tb3 " + css_class) unless user_id == session[:user_id]
    end
end