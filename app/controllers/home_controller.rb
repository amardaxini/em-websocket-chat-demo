class HomeController < ApplicationController
  def index
  end
  def chat
    @active_users = User.all
  end
end
