class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      update_user_activated user
    else
      flash[:danger] = I18n.t "controllers.account_activation.invalid_link"
      redirect_to root_url
    end
  end

  private
  def update_user_activated user
    user.update_attribute :activated, true
    user.update_attribute :activated_at, Time.zone.now
    log_in user
    flash[:success] = I18n.t "controllers.account_activation.account_activated"
    redirect_to user
  end
end
