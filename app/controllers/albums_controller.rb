class AlbumsController < ApplicationController
  before_action :require_login

  def index
    family = current_user.family_group

    # ガード（超重要）
    unless family
      @photos_by_year = {}
      return
    end

    photos = family.posts
                   .includes(:photos)
                   .flat_map(&:photos)

    @photos_by_year = photos.group_by { |photo| photo.created_at.year }
                            .sort.reverse.to_h
  end

  def require_login
    redirect_to root_path, alert: t('flash.login.required') if session[:user_id].blank?
  end
end
