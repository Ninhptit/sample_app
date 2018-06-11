class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        login user
      else
        message = I18n.t "controllers.session.not_actived"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = I18n.t "controllers.session.invalid_password"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def login user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end
end
