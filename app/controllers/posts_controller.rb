class PostsController < ApplicationController
  before_action :require_login

  def new
    @post = Post.new
    @has_family_group = current_user.family_group.present?
  end

  def create
    return render_without_images if no_images?

    build_post

    if @post.save
      attach_images
      redirect_to album_path(@post.album), notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :child_id, images: [])
  end

  # ------------------------
  # 以下：分割メソッド
  # ------------------------

  def no_images?
    params[:post][:images].blank?
  end

  def render_without_images
    @post = Post.new(post_params.except(:images))
    @post.errors.add(:base, '写真を1枚以上アップロードしてください')
    render :new, status: :unprocessable_entity
  end

  def build_post
    @post = current_user.posts.build(post_params.except(:images))
    @post.album = current_user.family_group.album
  end

  def attach_images
    params[:post][:images].each do |img|
      @post.photos.create!(image: img)
    end
  end
end
