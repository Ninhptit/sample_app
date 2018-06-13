class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :verify_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = I18n.t "controllers.micropost.micropost_created"
      redirect_to root_url
    else
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = I18n.t "controllers.micropost.micropost_deleted"
      redirect_to request.referrer
    else
      flash[:danger] = I18n.t "controllers.micropost.micropost_not_deleted"
      redirect_to root_url
    end
  end

  private
  def micropost_params
    params.require(:micropost).permit :content, :picture
  end

  def verify_user
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_url if @micropost.nil?
  end
end
