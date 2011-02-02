class ChatController < ApplicationController
  def index
    @active_users = User.all
  end

  def send_chat_data
   
    render :nothing => true

  end

end
