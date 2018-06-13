class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user,
    :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = I18n.t "controllers.password_reset.send_pass"
      redirect_to root_url
    else
      flash.now[:danger] = I18n.t "controllers.password_reset.email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("controllers.password_reset.not_empty")
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = I18n.t "controllers.password_reset.pass_has_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by email: params[:email]
    return if @user
    flash[:danger] = I18n.t "controllers.user.not_found"
    redirect_to root_path
  end

  def valid_user
    return if @user && @user.activated? &&
              @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = I18n.t "controllers.password_reset.password_expired"
    redirect_to new_password_reset_url
  end
end
