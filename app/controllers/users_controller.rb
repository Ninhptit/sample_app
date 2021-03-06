class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create, :show]
  before_action :verify_user, only: [:edit, :update]
  before_action :verify_admin!, only: :destroy
  before_action :find_user, only: %i(show edit update destroy)

  def index
    @users = User.all.page(params[:page]).per Settings.per_page
  end

  def new
    @user = User.new
  end

  def show
    redirect_to signup_path if @user.nil?
    @microposts = @user.microposts.all.page(params[:page]).per Settings.per_page
    @active_relationship = current_user.active_relationships.build
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = I18n.t "controllers.user.please_check_mail"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = I18n.t "controllers.user.profile_update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = I18n.t "controllers.user.user_destroyed"
      redirect_to users_url
    else
      flash[:danger] = I18n.t "controllers.user.not_destroyed"
      redirect_to root_url
    end
  end

  def following
    @title = I18n.t "controllers.user.following"
    @user  = User.find_by id: params[:id]
    @users = @user.following.page(params[:page]).per Settings.per_page
    render :show_follow
  end

  def followers
    @title = I18n.t "controllers.user.followers"
    @user  = User.find_by id: params[:id]
    @users = @user.followers.page(params[:page]).per Settings.per_page
    render :show_follow
  end

  private
  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = I18n.t "controllers.user.not_found"
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    flash[:danger] = I18n.t "controllers.user.please_login"
    redirect_to login_url
  end

  def verify_admin!
    redirect_to root_url unless current_user.admin?
  end

  def verify_user
    @user = User.find_by id: params[:id]
    redirect_to root_url unless @user.current_user? current_user
  end
end
