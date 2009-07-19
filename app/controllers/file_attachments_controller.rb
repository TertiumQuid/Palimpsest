class FileAttachmentsController < ApplicationController
    include ApplicationHelper
    
    # Provides a generic file handler, acting under the secure context of the requesting user
    def show
        # These are expected and required by the file_handler route: "file_attachments/:content_type/:parent_id/:id"
        id = params[:id]
        parent_id = params[:parent_id]
        
        case params[:content_type]
            when "PrivateMessage"   
                # Only users involved in PM conversations can view attachments
                file_attachment = PrivateMessage.with_recipients.with_user(session[:user_id]).with_attachments.find(parent_id).file_attachments.find(id)
            when "NewsArticle"
                file_attachment = NewsArticle.include_attachments.find(parent_id).file_attachments.find(id)
            else         
        end
        
        # Sanitize path to ensure that the path is not pointing anywhere malicious on the server 
        path = file_attachment.attachment.path
        raise MissingFile, "Couldn't read #{file_attachment.attachment_file_name}" unless
            File.readable?(path) and
            File.file?(path)
        
        send_file file_attachment.attachment.path, :type => file_attachment.attachment_content_type
    end
end