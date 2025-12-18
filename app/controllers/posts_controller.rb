class PostsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def new
    @post =
    if params[:draft_post_id]
      current_user.posts.find(params[:draft_post_id])
    else
      Post.new
    end

    @has_family_group = current_user.family_group.present?
  end

  def edit; end

  def create
    Rails.logger.debug { "POST PARAMS: #{post_params}" }

    if @post.update(post_params)
      redirect_to albums_path, notice: t('flash.posts.created')
    else
      @has_family_group = current_user.family_group.present?
      render :new, status: :unprocessable_entity
    end
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
    redirect_to albums_path, notice: t('flash.posts.deleted')
  end

  def select_photos
  end

  def confirm_photos

    if params[:images].blank?
      redirect_to select_photos_posts_path,
                  alert: "写真を1枚以上選択してください"
      return
    end

    post = current_user.posts.build(album: temp_album)
    post.save!(validate: false)

    params[:images].each do |img|
      post.photos.create!(image: img)
    end

    redirect_to new_post_path(draft_post_id: post.id)
  end

  private

  # ==================================================
  # Strong Parameters
  # ==================================================
  def post_params
    params.require(:post).permit(:title, :content, :child_id, :photo_date)
  end

  # ==================================================
  # Controller Flow
  # ==================================================

  #def build_and_save_post
    #build_post

    #if @post.save
      #handle_success
    #else
      #handle_failure
    #end
  #end

  #def assign_family_group_flag
    #@has_family_group = current_user.family_group.present?
  #end

  # ==================================================
  # Build
  # ==================================================

  #def build_post
    # Postオブジェクトをcurrent_userに紐づけて作成
    # 画像属性を除外してパラメータを渡す
    #@post = current_user.posts.build(post_params.except(:images))
    # 家族グループのアルバムを取得または作成して紐づけ
    #family = current_user.family_group
    # family に album があればそれを使う、なければ新規作成
    #album = family.album || family.create_album!
    # 上記で取得または作成した album を post に紐づけ
    #@post.album = album
  #end

  # ==================================================
  # Side Effects
  # ==================================================
  #def attach_images
    #return if session[:post_images].blank?

    #session[:post_images].each do |img|
      #@post.photos.create!(image: img)
    #end

    #session.delete(:post_images)
  #end

  # ==================================================
  # Response
  # ==================================================
  def handle_success
    attach_images
    redirect_to albums_path, notice: t('flash.posts.created')
  end

  def handle_failure
    Rails.logger.debug { "❌ save failed: #{@post.errors.full_messages}" }
    render :new, status: :unprocessable_entity
  end

  def temp_album
    family = current_user.family_group
    family.album || family.create_album!
  end

  # ==================================================
  # Before Actions
  # ==================================================

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.failed')
  end
end
