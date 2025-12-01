class AlbumsController < ApplicationController
  before_action :require_login

  def index
    @photos = Photo.all
  end

  def require_login
    redirect_to root_path, alert: t('flash.login.required') if session[:user_id].blank?
  end
end
