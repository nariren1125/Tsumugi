class PostsController < ApplicationController
  before_action :require_login

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.album_id = Album.first.id # 仮のアルバムに紐づける

    if @post.save
      redirect_to albums_path, notice: t('flash.posts.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :image, :photo_date, :child_id)
  end
end
