class PostsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def new
    @post = Post.new
    @has_family_group = current_user.family_group.present?
  end

  def edit; end

  def create
    Rails.logger.debug { "POST PARAMS: #{post_params}" }

    assign_family_group_flag
    build_and_save_post
  end

  def update
    if @post.update(post_params)
      redirect_to albums_path, notice: t('flash.posts.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to albums_path, notice: t('flash.posts.destroyed')
  end

  private

  # ==================================================
  # Strong Parameters
  # ==================================================
  def post_params
    params.require(:post).permit(:title, :content, :child_id, :photo_date, images: [])
  end

  # ==================================================
  # Controller Flow
  # ==================================================
  def build_and_save_post
    build_post

    if @post.save
      handle_success
    else
      handle_failure
    end
  end

  def assign_family_group_flag
    @has_family_group = current_user.family_group.present?
  end

  # ==================================================
  # Build
  # ==================================================

  def build_post
    # Postオブジェクトをcurrent_userに紐づけて作成
    # 画像属性を除外してパラメータを渡す
    @post = current_user.posts.build(post_params.except(:images))
    # 家族グループのアルバムを取得または作成して紐づけ
    family = current_user.family_group
    # family に album があればそれを使う、なければ新規作成
    album = family.album || family.create_album!
    # 上記で取得または作成した album を post に紐づけ
    @post.album = album
  end

  # ==================================================
  # Side Effects
  # ==================================================
  def attach_images
    return if no_images?

    params[:post][:images].each do |img|
      @post.photos.create!(image: img)
    end
  end

  # ==================================================
  # Validation
  # ==================================================
  def no_images?
    params[:post][:images].blank?
  end

  # ==================================================
  # Response
  # ==================================================
  def handle_success
    attach_images
    redirect_to albums_path, notice: t('.success')
  end

  def handle_failure
    Rails.logger.debug { "❌ save failed: #{@post.errors.full_messages}" }
    render :new, status: :unprocessable_entity
  end

  def render_without_images
    @post = Post.new(post_params.except(:images))
    @post.errors.add(:base, '写真を1枚以上アップロードしてください')
    render :new, status: :unprocessable_entity
  end

  # ==================================================
  # Before Actions
  # ==================================================

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.denied')
  end

  def delete_selected_photos
    return unless params[:delete_photos]

    params[:delete_photos].each do |photo_id|
      @post.photos.find(photo_id).destroy
    end
  end
end
