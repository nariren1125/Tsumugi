class PostsController < ApplicationController
  before_action :require_login

  def new; end

  def create
    redirect_to albums_path, notice: t('flash.posts.created')
  end
end
