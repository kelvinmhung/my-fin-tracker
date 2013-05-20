class HomeController < ApplicationController
  def index
    #@users = User.all
    if user_signed_in?
      @user = current_user
      @expenses  = current_user.expenses.all
    end
  end
end
