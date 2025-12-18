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

  def select_photos; end

  def confirm_photos
    return redirect_to_no_photos if params[:images].blank?

    post = build_draft_post
    attach_photos(post)

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
  # Confirm Photos Flow
  # ==================================================

  def redirect_to_no_photos
    redirect_to select_photos_posts_path,
                alert: t('flash.posts.no_photos_selected')
  end

  def build_draft_post
    post = current_user.posts.build(album: temp_album)
    post.save(validate: false)
    post
  end

  def attach_photos(post)
    params[:images].each do |img|
      post.photos.create!(image: img)
    end
  end

  # ==================================================
  # Album
  # ==================================================

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
